# Playbook: Nueva Feature

## Pasos

1. **Entender el contexto**: leer `docs/schema.md` para la BD, `docs/provider-map.md` para el estado
2. **Buscar features similares**: grep en `flutter_client/lib/features/` para patrones existentes
3. **Seguir la estructura estándar**:
   ```
   features/<feature>/
     data/           # Repository (Supabase)
     domain/         # Models + interfaces
     presentation/
       providers/    # Riverpod providers
       screens/      # Pantallas
       widgets/      # Componentes
   ```
4. **Auth**: usar `currentUserIdProvider`, NO `auth.uid()`
5. **SQL**: usar `current_app_user_id()`, crear RPCs security-definer para writes en `users`
6. **Strings UI**: español argentino
7. **Probar**: `cd flutter_client && flutter test`

## Reglas

- NO copiar lógica de couple mode sin verificar que aplica a family/friends
- Consultar `docs/playbooks/fix-expense.md` o `docs/playbooks/fix-task.md` si la feature toca esas áreas
- Consultar `docs/schema.md` antes de crear tablas o columnas nuevas
