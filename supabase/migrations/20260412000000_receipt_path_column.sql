-- Añade receipt_path a la tabla expenses.
-- Solo el path del objeto en Storage — nunca una URL pública.
-- Las signed URLs se generan en runtime con ReceiptScanService.getSignedUrl().
ALTER TABLE public.expenses
  ADD COLUMN IF NOT EXISTS receipt_path TEXT;
