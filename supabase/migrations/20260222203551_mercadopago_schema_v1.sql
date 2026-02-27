-- Add mercadopago_alias to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS mercadopago_alias TEXT;

-- Create mercadopago_connections table to store OAuth tokens
CREATE TABLE IF NOT EXISTS mercadopago_connections (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    mp_user_id TEXT,
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    public_key TEXT,
    live_mode BOOLEAN,
    token_type TEXT,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE mercadopago_connections ENABLE ROW LEVEL SECURITY;

-- Policies for mercadopago_connections
CREATE POLICY "Users can view their own connections" 
    ON mercadopago_connections FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own connections" 
    ON mercadopago_connections FOR UPDATE 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own connections" 
    ON mercadopago_connections FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Add comment for documentation
COMMENT ON COLUMN users.mercadopago_alias IS 'Mercado Pago Alias or CVU for direct transfers (0% commission)';
