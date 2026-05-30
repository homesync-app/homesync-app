-- Reconstructed from remote migration history (version 20260313232808).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Redefine ensure_planned_expenses to support filtering by household
-- This ensures visibility for the current and next month.
CREATE OR REPLACE FUNCTION public.ensure_planned_expenses(p_household_id UUID DEFAULT NULL)
RETURNS void AS $$
DECLARE
    today DATE := CURRENT_DATE;
    target_date DATE;
    template_row RECORD;
    computed_due_date DATE;
BEGIN
    FOR template_row IN 
        SELECT * FROM public.expense_templates 
        WHERE is_active = true 
        AND (p_household_id IS NULL OR household_id = p_household_id)
    LOOP
        
        -- A. Generate for current month
        target_date := date_trunc('month', today)::date;
        computed_due_date := (date_trunc('month', target_date) + (template_row.day_of_month - 1) * interval '1 day')::date;
        
        -- Handle date clamping (e.g., Feb 31 -> Feb 28)
        IF date_part('month', computed_due_date) != date_part('month', target_date) THEN
            computed_due_date := (date_trunc('month', target_date + interval '1 month') - interval '1 day')::date;
        END IF;

        INSERT INTO public.planned_expenses (
            household_id, template_id, title, amount, category, 
            due_date, split_type, payer_default, status
        ) VALUES (
            template_row.household_id,
            template_row.id,
            template_row.title,
            template_row.default_amount,
            template_row.category,
            computed_due_date,
            template_row.split_type,
            template_row.payer_default,
            'pending'
        ) ON CONFLICT (template_id, due_date) DO NOTHING;

        -- B. Generate for next month
        target_date := (date_trunc('month', today) + interval '1 month')::date;
        computed_due_date := (date_trunc('month', target_date) + (template_row.day_of_month - 1) * interval '1 day')::date;
        
        -- Handle date clamping
        IF date_part('month', computed_due_date) != date_part('month', target_date) THEN
            computed_due_date := (date_trunc('month', target_date + interval '1 month') - interval '1 day')::date;
        END IF;

        INSERT INTO public.planned_expenses (
            household_id, template_id, title, amount, category, 
            due_date, split_type, payer_default, status
        ) VALUES (
            template_row.household_id,
            template_row.id,
            template_row.title,
            template_row.default_amount,
            template_row.category,
            computed_due_date,
            template_row.split_type,
            template_row.payer_default,
            'pending'
        ) ON CONFLICT (template_id, due_date) DO NOTHING;

    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Enhance process_recurring_expenses to be smarter
-- It should ensure planned expenses exist for the household AND advance the template pointer.
CREATE OR REPLACE FUNCTION public.process_recurring_expenses(p_household_id UUID DEFAULT NULL)
RETURNS jsonb AS $$
DECLARE
    v_template RECORD;
    v_count INTEGER := 0;
    v_next_month DATE;
    v_next_date DATE;
BEGIN
    -- First, ensure visibility for current/next month (like the cron job)
    PERFORM public.ensure_planned_expenses(p_household_id);

    -- Now, for templates whose next_execution_date is in the past/today,
    -- ensure they have a planned expense and ADVANCE them.
    -- This is crucial for monthly roll-over.
    FOR v_template IN 
        SELECT * FROM public.expense_templates 
        WHERE is_active = true 
          AND next_execution_date <= CURRENT_DATE
          AND (p_household_id IS NULL OR household_id = p_household_id)
    LOOP
        -- Ensure the planned expense exists (might have been created by ensure_planned_expenses)
        INSERT INTO public.planned_expenses (
            household_id, template_id, title, amount, category, 
            split_type, payer_default, due_date, status
        ) VALUES (
            v_template.household_id, v_template.id, v_template.title, 
            v_template.default_amount, v_template.category, 
            v_template.split_type, v_template.payer_default, 
            v_template.next_execution_date, 'pending'
        ) ON CONFLICT (template_id, due_date) DO NOTHING;

        -- ADVANCE the next_execution_date
        IF v_template.frequency = 'monthly' THEN
            v_next_month := v_template.next_execution_date + INTERVAL '1 month';
            v_next_date := make_date(
                EXTRACT(year FROM v_next_month)::int,
                EXTRACT(month FROM v_next_month)::int,
                LEAST(v_template.day_of_month, EXTRACT(day FROM (date_trunc('month', v_next_month) + INTERVAL '1 month - 1 day'))::int)
            );
        ELSIF v_template.frequency = 'weekly' THEN
            v_next_date := v_template.next_execution_date + INTERVAL '1 week';
        ELSE
            v_next_date := v_template.next_execution_date + INTERVAL '1 month';
        END IF;

        UPDATE public.expense_templates 
        SET next_execution_date = v_next_date, updated_at = NOW() 
        WHERE id = v_template.id;

        v_count := v_count + 1;
    END LOOP;

    RETURN jsonb_build_object('success', true, 'processed_count', v_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Create Trigger to handle template updates (Clean-up stale pending expenses)
CREATE OR REPLACE FUNCTION public.handle_template_update_sync()
RETURNS TRIGGER AS $$
BEGIN
    -- Only trigger if significant fields changed (day, amount, title, active status)
    IF (TG_OP = 'UPDATE') AND 
       (OLD.day_of_month = NEW.day_of_month AND 
        OLD.default_amount = NEW.default_amount AND 
        OLD.title = NEW.title AND 
        OLD.is_active = NEW.is_active) THEN
        RETURN NEW;
    END IF;

    -- If the template is de-activated, delete planned items
    IF (NEW.is_active = false) THEN
        DELETE FROM public.planned_expenses 
        WHERE template_id = NEW.id AND status = 'pending';
        RETURN NEW;
    END IF;

    -- If day of month changed or template re-activated,
    -- delete pending ones for THIS template and let process_recurring_expenses recreate them.
    -- Warning: We only delete 'pending' ones to avoid deleting 'paid' or 'skipped' history.
    DELETE FROM public.planned_expenses 
    WHERE template_id = NEW.id AND status = 'pending';
    
    -- We don't call process_recurring_expenses here because we are inside a trigger on expense_templates.
    -- The app will call process_recurring_expenses right after saving the template anyway.
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS tr_sync_planned_expenses ON public.expense_templates;
CREATE TRIGGER tr_sync_planned_expenses
AFTER INSERT OR UPDATE ON public.expense_templates
FOR EACH ROW EXECUTE FUNCTION public.handle_template_update_sync();
;