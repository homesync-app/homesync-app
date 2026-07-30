-- Reconstructed from remote migration history (version 20260310133030).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- PHASE 3: AUTOMATION (CRON JOB)
CREATE OR REPLACE FUNCTION ensure_planned_expenses()
RETURNS void AS $$
DECLARE
    today DATE := CURRENT_DATE;
    target_date DATE;
    template_row RECORD;
    computed_due_date DATE;
BEGIN
    FOR template_row IN SELECT * FROM expense_templates WHERE is_active = true LOOP
        -- Generate for current month
        target_date := date_trunc('month', today)::date;
        computed_due_date := (date_trunc('month', target_date) + (template_row.day_of_month - 1) * interval '1 day')::date;
        IF date_part('month', computed_due_date) != date_part('month', target_date) THEN
            computed_due_date := (date_trunc('month', target_date + interval '1 month') - interval '1 day')::date;
        END IF;
        INSERT INTO planned_expenses (household_id, template_id, title, amount, category, due_date, split_type, payer_default, status)
        VALUES (template_row.household_id, template_row.id, template_row.title, template_row.default_amount, template_row.category, computed_due_date, template_row.split_type, template_row.payer_default, 'pending')
        ON CONFLICT (template_id, due_date) DO NOTHING;

        -- Generate for next month
        target_date := (date_trunc('month', today) + interval '1 month')::date;
        computed_due_date := (date_trunc('month', target_date) + (template_row.day_of_month - 1) * interval '1 day')::date;
        IF date_part('month', computed_due_date) != date_part('month', target_date) THEN
            computed_due_date := (date_trunc('month', target_date + interval '1 month') - interval '1 day')::date;
        END IF;
        INSERT INTO planned_expenses (household_id, template_id, title, amount, category, due_date, split_type, payer_default, status)
        VALUES (template_row.household_id, template_row.id, template_row.title, template_row.default_amount, template_row.category, computed_due_date, template_row.split_type, template_row.payer_default, 'pending')
        ON CONFLICT (template_id, due_date) DO NOTHING;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Schedule the job (Note: if pg_cron is not available, this might fail, but let's try)
-- On Supabase, you might need to use the dashboard, but if pg_cron extension is enabled, this works.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        PERFORM cron.schedule('generate-planned-expenses', '0 3 * * *', 'SELECT ensure_planned_expenses()');
    END IF;
END $$;
;