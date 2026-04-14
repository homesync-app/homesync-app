import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Edge Function invocada via cron (Supabase Cron) una vez por día.
// Elimina tickets del bucket 'receipts' con más de 60 días usando la
// Storage API con service role — más seguro que DELETE sobre storage.objects.
//
// Estructura del bucket: receipts/{household_id}/{uuid}.webp
// → Primero lista carpetas raíz (household_ids), luego archivos dentro de cada una.
//
// Configurar en Supabase Dashboard > Edge Functions > Cron:
//   Schedule: 0 3 * * *  (3am UTC diario)
//   Function: cleanup-old-receipts

const RETENTION_DAYS = 60;
const BUCKET = "receipts";
const PAGE_SIZE = 100;

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  const cronSecret = Deno.env.get("CRON_SECRET");

  const isCron = cronSecret && authHeader === `Bearer ${cronSecret}`;
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
    `[cleanup-old-receipts] Cutoff: ${cutoff.toISOString()}`
  );

  let totalDeleted = 0;
  const errors: string[] = [];

  // ── Paso 1: listar carpetas raíz (= household_ids) ────────────────────────
  let folderOffset = 0;
  const householdFolders: string[] = [];

  while (true) {
    const { data: roots, error } = await supabase.storage
      .from(BUCKET)
      .list("", { limit: PAGE_SIZE, offset: folderOffset });

    if (error) {
      console.error("[cleanup-old-receipts] Error listando raíz:", error);
      break;
    }
    if (!roots || roots.length === 0) break;

    // En Storage, las entradas sin extensión son carpetas
    for (const entry of roots) {
      if (!entry.name.includes(".")) {
        householdFolders.push(entry.name);
      }
    }

    if (roots.length < PAGE_SIZE) break;
    folderOffset += PAGE_SIZE;
  }

  console.log(
    `[cleanup-old-receipts] Carpetas de hogar encontradas: ${householdFolders.length}`
  );

  // ── Paso 2: dentro de cada carpeta, listar archivos y borrar los viejos ───
  for (const folder of householdFolders) {
    let fileOffset = 0;

    while (true) {
      const { data: files, error: listError } = await supabase.storage
        .from(BUCKET)
        .list(folder, {
          limit: PAGE_SIZE,
          offset: fileOffset,
          sortBy: { column: "created_at", order: "asc" },
        });

      if (listError) {
        console.error(
          `[cleanup-old-receipts] Error listando ${folder}:`,
          listError
        );
        errors.push(`${folder}: ${listError.message}`);
        break;
      }

      if (!files || files.length === 0) break;

      const toDelete = files
        .filter((f) => {
          const created = new Date(f.created_at ?? "");
          return !isNaN(created.getTime()) && created < cutoff;
        })
        .map((f) => `${folder}/${f.name}`); // path completo requerido por .remove()

      if (toDelete.length > 0) {
        const { error: deleteError } = await supabase.storage
          .from(BUCKET)
          .remove(toDelete);

        if (deleteError) {
          console.error(
            `[cleanup-old-receipts] Error borrando en ${folder}:`,
            deleteError
          );
          errors.push(`${folder}: ${deleteError.message}`);
        } else {
          totalDeleted += toDelete.length;
          console.log(
            `[cleanup-old-receipts] ${folder}: eliminados ${toDelete.length} archivos`
          );
        }
      }

      if (files.length < PAGE_SIZE) break;
      fileOffset += PAGE_SIZE;
    }
  }

  const result = {
    deleted: totalDeleted,
    households_scanned: householdFolders.length,
    errors: errors.length > 0 ? errors : undefined,
    retention_days: RETENTION_DAYS,
    cutoff: cutoff.toISOString(),
  };

  console.log("[cleanup-old-receipts] Resultado:", result);

  return new Response(JSON.stringify(result), {
    headers: { "Content-Type": "application/json" },
  });
});
