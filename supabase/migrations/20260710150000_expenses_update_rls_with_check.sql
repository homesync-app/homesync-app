-- RLS: UPDATE de expenses con WITH CHECK explícito.
--
-- La policy "Users can update own expenses" solo tenía USING
-- (created_by_id = current_app_user_id()); sin WITH CHECK, Postgres reutiliza
-- el USING para la fila nueva, que no valida household_id: el creador podía
-- mover su gasto a OTRO hogar (inyección de datos en un hogar ajeno) vía
-- UPDATE directo a la tabla. El cliente no usa ese camino (va por RPC), pero
-- la tabla queda expuesta por PostgREST.
--
-- WITH CHECK: seguís siendo el creador Y tenés que ser miembro del hogar
-- destino. Mover un gasto entre dos hogares propios sigue permitido.

ALTER POLICY "Users can update own expenses" ON public.expenses
  USING (created_by_id = public.current_app_user_id())
  WITH CHECK (
    created_by_id = public.current_app_user_id()
    AND public.is_current_household_member(household_id)
  );
