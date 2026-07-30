-- Reconstructed from remote migration history (version 20260303002808).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- ============================================
-- FIX LOGGING PERMISSIONS MIGRATION
-- Allow unauthenticated clients to log errors
-- ============================================

-- Ensure the application_logs table exists if not already present
-- (It seems it was created manually or in a phantom migration)
CREATE TABLE IF NOT EXISTS public.application_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    level TEXT NOT NULL DEFAULT 'info',
    message TEXT NOT NULL,
    stack_trace TEXT,
    context JSONB DEFAULT '{}',
    device_info JSONB DEFAULT '{}',
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Enable RLS
ALTER TABLE public.application_logs ENABLE ROW LEVEL SECURITY;

-- Allow anyone to insert logs (so we can capture login errors)
-- We use a permissive policy for INSERT
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'application_logs' AND policyname = 'Allow anyone to insert logs'
    ) THEN
        CREATE POLICY "Allow anyone to insert logs" 
        ON public.application_logs 
        FOR INSERT 
        TO anon, authenticated 
        WITH CHECK (true);
    END IF;
END $$;

-- Only authenticated users can view logs
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'application_logs' AND policyname = 'Allow authenticated users to view logs'
    ) THEN
        CREATE POLICY "Allow authenticated users to view logs" 
        ON public.application_logs 
        FOR SELECT 
        TO authenticated 
        USING (true);
    END IF;
END $$;

-- Allow authenticated users to delete logs
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'application_logs' AND policyname = 'Allow authenticated users to delete logs'
    ) THEN
        CREATE POLICY "Allow authenticated users to delete logs" 
        ON public.application_logs 
        FOR DELETE 
        TO authenticated 
        USING (true);
    END IF;
END $$;

-- Grant permissions
GRANT INSERT ON public.application_logs TO anon;
GRANT ALL ON public.application_logs TO authenticated;
GRANT ALL ON public.application_logs TO service_role;
;