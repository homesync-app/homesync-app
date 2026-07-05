# Android QA Smoke Test

Playbook para validar HomeSync en Android con los escenarios QA existentes.

## Entrada QA

Launcher generico:

```powershell
.\scripts\run_android_qa.ps1 -Scenario family
```

Con sesion real del usuario QA:

```powershell
.\scripts\run_android_qa.ps1 -Scenario family -RealQaSession
```

Seleccionar dispositivo manualmente:

```powershell
.\scripts\run_android_qa.ps1 -DeviceId R5CY10QFHYT -Scenario family
```

Escenarios disponibles:

| Scenario | Viewer default | Usuario |
| --- | --- | --- |
| `solo` | `11110000-0000-0000-0000-000000000001` | `qa.solo.luna@homesync.local` |
| `couple` | `22220000-0000-0000-0000-000000000001` | `qa.couple.alex@homesync.local` |
| `friends` | `33330000-0000-0000-0000-000000000001` | `qa.friends.nico@homesync.local` |
| `family` | `44440000-0000-0000-0000-000000000001` | `qa.family.blas@homesync.local` |

El launcher usa:

- `APP_ENV=staging`
- `AUTH_MODE=supabase_native`
- `ENABLE_ADMIN_TESTING=true`
- admin preview: `admin / superadmin`
- base session: `test@homesync.com / qapass123`

## Evidencia

Capturar pantalla, UI tree, logcat, memoria y framestats:

```powershell
.\scripts\capture_android_qa_evidence.ps1
```

Salida por defecto:

```text
artifacts/android-qa/<timestamp>/
  screen.png
  ui.xml
  logcat.txt
  meminfo.txt
  gfxinfo-framestats.txt
```

## Smoke minimo

Antes de tocar RLS/RPC/security definer/storage policies, dejar evidencia de:

1. Completar una tarea normal.
2. Completar una tarea recurrente.
3. Aprobar/verificar una tarea pendiente.
4. Enviar feedback desde Settings.
5. Crear o usar una solicitud del catalogo de shopping.
6. Cargar el feed de finanzas.

## QA de feeling premium

Despues de cambios UI/mobile, revisar:

1. Press states: botones, cards, tabs y chips responden de inmediato.
2. Haptics: no hay vibracion duplicada; solo confirma cambios de estado.
3. Keyboard: inputs y submit siguen visibles en sheets/dialogs.
4. Loading: dashboards/listas usan skeletons, no pantallas vacias con spinner.
5. Empty states: explican que pasa y ofrecen siguiente accion cuando corresponde.

## Notas

- No usar estos defines en production.
- Si no aparece un dispositivo, correr `flutter devices` o iniciar un emulador con `flutter emulators`.
- Si `adb` no esta en PATH, `capture_android_qa_evidence.ps1` intenta resolverlo desde `ANDROID_HOME`, `ANDROID_SDK_ROOT` o `%LOCALAPPDATA%\Android\Sdk`.
