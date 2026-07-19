-- Telemetría de precisión del OCR + detección de scans duplicados.
--
-- Hasta ahora ocr_scan_logs guardaba merchant/confianza/items pero NO el
-- monto/fecha/categoría que detectó la IA ni lo que el usuario terminó
-- guardando. Resultado: desde el panel admin era imposible medir si el OCR
-- lee bien el monto — el campo más importante del gasto. Un usuario que
-- corrige el monto a mano en cada scan es un scan fallido aunque figure
-- user_action = 'confirmed'.
--
-- Columnas nuevas:
--   - ai_*: lo que devolvió Gemini (las escribe la Edge Function).
--   - final_* / amount_edited: lo que el usuario confirmó al guardar el
--     gasto (las escribe el cliente vía RLS "users update own logs").
--   - image_hash / duplicate_of: SHA-256 de la imagen subida; la Edge
--     Function lo usa para avisar cuando el mismo ticket se escanea dos
--     veces (el 2026-06-07 un mismo ticket se procesó 6 veces contra el
--     endpoint pago de Gemini).

alter table public.ocr_scan_logs
  add column if not exists ai_amount numeric,
  add column if not exists ai_date date,
  add column if not exists ai_category text,
  add column if not exists image_hash text,
  add column if not exists duplicate_of uuid,
  add column if not exists final_amount numeric,
  add column if not exists final_category text,
  add column if not exists amount_edited boolean;

comment on column public.ocr_scan_logs.ai_amount is
  'Monto total que detectó la IA. Comparar contra final_amount para medir precisión del OCR.';
comment on column public.ocr_scan_logs.ai_date is
  'Fecha del ticket detectada por la IA (ya validada: ni futura ni >1 año).';
comment on column public.ocr_scan_logs.ai_category is
  'Categoría sugerida por la IA (enum del prompt, ya normalizada).';
comment on column public.ocr_scan_logs.image_hash is
  'SHA-256 (hex) de los bytes de imagen recibidos. Solo path binario.';
comment on column public.ocr_scan_logs.duplicate_of is
  'Id del scan exitoso previo del mismo household con igual image_hash (48h). La Edge Function lo setea y avisa al cliente.';
comment on column public.ocr_scan_logs.final_amount is
  'Monto que el usuario terminó guardando en el gasto. NULL si canceló.';
comment on column public.ocr_scan_logs.final_category is
  'Categoría final del gasto guardado.';
comment on column public.ocr_scan_logs.amount_edited is
  'true si el usuario modificó el monto que pre-llenó el OCR antes de guardar.';

-- Lookup de duplicados: mismo household + mismo hash en ventana reciente.
create index if not exists idx_ocr_scan_logs_dedup
  on public.ocr_scan_logs (household_id, image_hash, created_at desc)
  where image_hash is not null;
