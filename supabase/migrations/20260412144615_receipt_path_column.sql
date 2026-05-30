-- Reconstructed from remote migration history (version 20260412144615).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Aâ”œâ–’ade receipt_path a la tabla expenses.
-- Solo el path del objeto en Storage Ã”Ã‡Ã¶ nunca una URL pâ”œâ•‘blica.
-- Las signed URLs se generan en runtime con ReceiptScanService.getSignedUrl().
ALTER TABLE public.expenses
  ADD COLUMN IF NOT EXISTS receipt_path TEXT;
