# HomeSync Mobile - Checklist Final Play Store

## 1. Calidad de Producto (bloqueante)
- [ ] Flujo de tareas validado en dispositivo real: crear, editar, programar, completar, re-completar.
- [ ] Home refleja estado correcto: tarea completada desaparece de "Tareas de hoy" y queda en actividad.
- [ ] Finanzas y recompensas sin regresiones (casos básicos online/offline).
- [ ] Sin textos rotos por encoding en pantallas críticas (Home, Tareas, Settings).

## 2. Calidad Técnica (bloqueante)
- [ ] `flutter analyze` sin errores.
- [ ] Suite mínima de tests verdes (`tasks`, `finance`, `rewards`, `offline`).
- [ ] Crash-free smoke test (arranque, login, navegación principal, acciones core).
- [ ] Logs de debug temporales removidos.

## 3. Android Release (bloqueante)
- [ ] `versionCode` incrementado y `versionName` actualizado en `android/app/build.gradle`.
- [ ] Firma release configurada y validada (`key.properties` + keystore correcto).
- [ ] Build release AAB:
  - `flutter build appbundle --release`
- [ ] Test de instalación interna con ese build.

## 4. Seguridad y Datos (bloqueante)
- [ ] Variables de entorno de producción correctas (Supabase/Firebase).
- [ ] Revisión RLS en tablas críticas (`tasks`, `household_activities`, `ledger_entries`).
- [ ] Sin secretos hardcodeados en app.
- [ ] Política de privacidad publicada y URL funcional.

## 5. Play Console (bloqueante)
- [ ] Ficha de tienda completa: título, descripción corta/larga, categoría.
- [ ] Capturas reales actualizadas (teléfono, flujo actual de UI).
- [ ] Ícono 512x512 y feature graphic cargados.
- [ ] Data safety form completado con datos reales.
- [ ] Content rating + target audience + anuncios definidos.
- [ ] Testing track configurado (internal/closed) con testers activos.

## 6. Pre-lanzamiento (recomendado fuerte)
- [ ] Correr Pre-launch report de Google y corregir bloqueantes.
- [ ] Verificar performance básica (cold start, navegación principal).
- [ ] Revisar crashes y ANR en Android Vitals del track de prueba.

## 7. Go/No-Go
- [ ] QA funcional aprobada.
- [ ] QA visual aprobada.
- [ ] QA legal/compliance aprobada.
- [ ] Decisión final de publicación documentada.

## Comandos útiles
```bash
flutter clean
flutter pub get
flutter test -r compact
flutter build appbundle --release
```

