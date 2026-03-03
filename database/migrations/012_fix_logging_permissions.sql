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
CREATE POLICY "Allow anyone to insert logs" 
ON public.application_logs 
FOR INSERT 
TO anon, authenticated 
WITH CHECK (true);

-- Only authenticated users can view logs (Admin panel users will be authenticated)
-- Actually, the admin panel usually has its own checks, but let's keep it safe.
CREATE POLICY "Allow authenticated users to view logs" 
ON public.application_logs 
FOR SELECT 
TO authenticated 
USING (true);

-- Allow authenticated users to delete logs (for the Clear Logs button)
CREATE POLICY "Allow authenticated users to delete logs" 
ON public.application_logs 
FOR DELETE 
TO authenticated 
USING (true);

-- Grant permissions
GRANT INSERT ON public.application_logs TO anon;
GRANT ALL ON public.application_logs TO authenticated;
GRANT ALL ON public.application_logs TO service_role;
