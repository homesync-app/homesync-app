-- Reconstructed from remote migration history (version 20260223002746).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Create table for logging Mercado Pago webhooks
CREATE TABLE IF NOT EXISTS public.mercadopago_webhooks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mp_id TEXT UNIQUE NOT NULL,
    topic TEXT,
    action TEXT,
    live_mode BOOLEAN,
    payload JSONB NOT NULL,
    status TEXT DEFAULT 'pending', -- pending, processed, failed
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Enable RLS
ALTER TABLE public.mercadopago_webhooks ENABLE ROW LEVEL SECURITY;

-- Index for quick lookup by ID to avoid duplicates
CREATE INDEX IF NOT EXISTS idx_mp_id ON public.mercadopago_webhooks(mp_id);
;