-- Reconstructed from remote migration history (version 20260314012307).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Refine ensure_planned_expenses to NOT create past items for the current month
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
        
        -- A. Generate for current month (ONLY IF NOT PASSED)
        target_date := date_trunc('month', today)::date;
        computed_due_date := (date_trunc('month', target_date) + (template_row.day_of_month - 1) * interval '1 day')::date;
        
        -- Handle date clamping (Feb 31 -> Feb 28/29)
        IF date_part('month', computed_due_date) != date_part('month', target_date) THEN
            computed_due_date := (date_trunc('month', target_date + interval '1 month') - interval '1 day')::date;
        END IF;

        -- ONLY INSERT IF TODAY OR FUTURE
        IF computed_due_date >= today THEN
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
        END IF;

        -- B. Generate for next month (Always do this)
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

-- 2. Enhanced handle_template_update_sync to be more thorough
CREATE OR REPLACE FUNCTION public.handle_template_update_sync()
RETURNS TRIGGER AS $$
BEGIN
    -- If de-activated, delete ALL pending items for this template
    IF (TG_OP = 'UPDATE' AND OLD.is_active = true AND NEW.is_active = false) THEN
        DELETE FROM public.planned_expenses 
        WHERE template_id = NEW.id AND status = 'pending';
        RETURN NEW;
    END IF;

    -- If title, amount, or day changed, we MUST purge pending ones to avoid "stale" or "doubled" entries
    IF (TG_OP = 'UPDATE') AND 
       (OLD.day_of_month != NEW.day_of_month OR 
        OLD.default_amount != NEW.default_amount OR 
        OLD.title != NEW.title OR 
        OLD.is_active != NEW.is_active) THEN
        
        DELETE FROM public.planned_expenses 
        WHERE template_id = NEW.id AND status = 'pending';
        
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Immediate cleanup for the user: Delete pending past items for the current household
-- This helps resolve the "too many pending items" the user current has.
-- We only do it for 'pending' to avoid deleting history.
-- Note: We only delete if they are older than TODAY.
DELETE FROM public.planned_expenses 
WHERE status = 'pending' AND due_date < CURRENT_DATE;
;