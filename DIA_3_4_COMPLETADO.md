# 🚀 INSTRUCCIONES PARA CORRER FLUTTER CON SUPABASE

## ✅ LO QUE SE HIZO EN DÍA 3-4

### 1. Agregada dependencia de Supabase
```yaml
dependencies:
  supabase_flutter: ^2.6.0
```

### 2. Creado SupabaseAuthService
- Servicio para manejar auth de Supabase
- Métodos: signUp, signIn, signOut, resetPassword
- Session management incluido
- Token management incluido

### 3. Actualizado main.dart
- Inicialización de Supabase
- LoginScreen usando Supabase Auth
- TasksScreen usando Supabase Auth
- Eliminado TaskService anterior

### 4. Configuración de entornos actualizada
- Supabase URL configurada
- Supabase Anon Key configurada
- Variables de entorno centralizadas

---

## 🚀 PASOS PARA CORRER LA APP

### PASO 1: Instalar dependencias

```bash
cd flutter_client
flutter pub get
```

### PASO 2: Limpiar cache y correr

```bash
flutter clean
flutter run
```

### PASO 3: Probar Auth Flow

1. **Crear cuenta nueva:**
   - Ingresar email
   - Ingresar password
   - Click "Crear cuenta"
   - ✅ Debería crear usuario en Supabase
   - ✅ Debería navegar a pantalla de tareas

2. **Cerrar sesión:**
   - Click "Cerrar sesión"
   - ✅ Debería volver a pantalla de login

3. **Iniciar sesión:**
   - Ingresar email
   - Ingresar password
   - Click "Iniciar Sesión"
   - ✅ Debería autenticar con Supabase
   - ✅ Debería navegar a pantalla de tareas

---

## 📊 CRITERIOS DE ÉXITO PARA DÍA 3-4

| Criterio | Estado |
|----------|--------|
| Dependencia supabase_flutter agregada | ✅ COMPLETO |
| SupabaseAuthService creado | ✅ COMPLETO |
| main.dart actualizado | ✅ COMPLETO |
| LoginScreen usando Supabase | ✅ COMPLETO |
| TasksScreen usando Supabase | ✅ COMPLETO |
| SignUp funcional | ⏳ PENDIENTE DE PROBAR |
| Login funcional | ⏳ PENDIENTE DE PROBAR |
| Logout funcional | ⏳ PENDIENTE DE PROBAR |
| Token refresh automático | ⏳ PENDIENTE (Día 5-6) |

---

## 🎯 PRÓXIMOS PASOS

### DÍA 5-6: Implementar Endpoints via RPC
1. Implementar llamadas a RPC functions desde Flutter
2. Implementar create_task
3. Implementar complete_task_transaction
4. Implementar verify_task_transaction
5. Implementar get_user_balance
6. Implementar idempotencia en cliente Flutter
7. Probar todos los endpoints

---

## ✅ CONCLUSIÓN

**Día 3-4 está COMPLETADO en código.**

La integración con Supabase Auth está lista para:
- ✅ Sign up nuevos usuarios
- ✅ Sign in usuarios existentes
- ✅ Sign out usuarios
- ✅ Session management

**Próximo paso:** Correr la app y probar el auth flow, luego implementar endpoints RPC (Día 5-6)

🚀 **VAMOS A PROBAR EL AUTH FLOW.**
