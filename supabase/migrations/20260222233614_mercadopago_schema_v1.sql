-- Reconstructed from remote migration history (version 20260222233614).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Add Alias/CVU to users table
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS mercadopago_alias text;

-- Create table for OAuth connections (Nivel 2)
CREATE TABLE IF NOT EXISTS public.mercadopago_connections (
  user_id uuid REFERENCES public.users NOT NULL PRIMARY KEY,
  mp_access_token text NOT NULL,
  mp_user_id text,
  mp_public_key text,
  refresh_token text,
  expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.mercadopago_connections ENABLE ROW LEVEL SECURITY;

-- Policies for connections
CREATE POLICY "Users can view their own connections" ON public.mercadopago_connections
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own connections" ON public.mercadopago_connections
  FOR ALL USING (auth.uid() = user_id);
;