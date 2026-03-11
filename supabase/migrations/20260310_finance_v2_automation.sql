-- PHASE 3: AUTOMATION (CRON JOB)
-- This logic ensures planned expenses are generated daily.

-- Enable pg_cron if not enabled (usually requires superuser or being in a specific environment, 
-- but on Supabase it's available in the dashboard).
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 1. Function to bridge the period generation
CREATE OR REPLACE FUNCTION ensure_planned_expenses()
RETURNS void AS $$
DECLARE
    today DATE := CURRENT_DATE;
    target_date DATE;
    template_row RECORD;
    computed_due_date DATE;
BEGIN
    -- We want to generate planned expenses for the current month and the next month
    -- to give users visibility into their upcoming finances.
    
    FOR template_row IN SELECT * FROM expense_templates WHERE is_active = true LOOP
        
        -- Generate for current month
        target_date := date_trunc('month', today)::date;
        computed_due_date := (date_trunc('month', target_date) + (template_row.day_of_month - 1) * interval '1 day')::date;
        
        -- Handle date clamping (e.g., Feb 31 -> Feb 28)
        IF date_part('month', computed_due_date) != date_part('month', target_date) THEN
            computed_due_date := (date_trunc('month', target_date + interval '1 month') - interval '1 day')::date;
        END IF;

        INSERT INTO planned_expenses (
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

        -- Generate for next month
        target_date := (date_trunc('month', today) + interval '1 month')::date;
        computed_due_date := (date_trunc('month', target_date) + (template_row.day_of_month - 1) * interval '1 day')::date;
        
        -- Handle date clamping
        IF date_part('month', computed_due_date) != date_part('month', target_date) THEN
            computed_due_date := (date_trunc('month', target_date + interval '1 month') - interval '1 day')::date;
        END IF;

        INSERT INTO planned_expenses (
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
$$ LANGUAGE plpgsql;

-- 2. Schedule the job (Run every day at 03:00 AM)
-- Note: In a real migration, you'd check if it exists or use a tool to manage cron.
-- This is the Supabase/Postgres way to register it.
SELECT cron.schedule('generate-planned-expenses', '0 3 * * *', 'SELECT ensure_planned_expenses()');
