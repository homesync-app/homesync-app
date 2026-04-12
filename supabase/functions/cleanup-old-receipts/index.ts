import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Edge Function invocada via cron (Supabase Cron) una vez por día.
// Elimina tickets del bucket 'receipts' con más de 60 días usando la
// Storage API con service role — más seguro que DELETE sobre storage.objects.
//
// Configurar en Supabase Dashboard > Edge Functions > Cron:
//   Schedule: 0 3 * * *  (3am UTC diario)
//   Function: cleanup-old-receipts

const RETENTION_DAYS = 60;
const BUCKET = "receipts";

serve(async (req) => {
  // Solo aceptar requests del cron interno de Supabase o autenticados
  const authHeader = req.headers.get("Authorization");
  const cronSecret = Deno.env.get("CRON_SECRET");

  // Validar: o es el cron con su secret, o un admin autenticado
  const isCron =
    cronSecret && authHeader === `Bearer ${cronSecret}`;
  const isServiceRole =
    authHeader === `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`;

  if (!isCron && !isServiceRole) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
  );

  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - RETENTION_DAYS);

  console.log(
    `[cleanup-old-receipts] Buscando archivos anteriores a ${cutoff.toISOString()}`
  );

  // Listar todos los archivos del bucket (paginado para escalar)
  let totalDeleted = 0;
  let offset = 0;
  const PAGE_SIZE = 100;
  const errors: string[] = [];

  while (true) {
    const { data: files, error: listError } = await supabase.storage
      .from(BUCKET)
      .list("", {
        limit: PAGE_SIZE,
        offset,
        sortBy: { column: "created_at", order: "asc" },
      });

    if (listError) {
      console.error("[cleanup-old-receipts] Error listando:", listError);
      break;
    }

    if (!files || files.length === 0) break;

    // Filtrar los que superan el tiempo de retención
    const toDelete = files
      .filter((f) => {
        const created = new Date(f.created_at ?? "");
        return created < cutoff;
      })
      .map((f) => f.name);

    if (toDelete.length > 0) {
      const { error: deleteError } = await supabase.storage
        .from(BUCKET)
        .remove(toDelete);

      if (deleteError) {
        console.error("[cleanup-old-receipts] Error borrando:", deleteError);
        errors.push(deleteError.message);
      } else {
        totalDeleted += toDelete.length;
        console.log(
          `[cleanup-old-receipts] Eliminados ${toDelete.length} archivos`
        );
      }
    }

    // Si la página está completa seguimos paginando; si no, terminamos
    if (files.length < PAGE_SIZE) break;
    offset += PAGE_SIZE;
  }

  const result = {
    deleted: totalDeleted,
    errors: errors.length > 0 ? errors : undefined,
    retention_days: RETENTION_DAYS,
    cutoff: cutoff.toISOString(),
  };

  console.log("[cleanup-old-receipts] Resultado:", result);

  return new Response(JSON.stringify(result), {
    headers: { "Content-Type": "application/json" },
  });
});
