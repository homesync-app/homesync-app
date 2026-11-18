#!/bin/bash
# Captura cruda para goldie SIN reinstalar la app (goldie capture desinstala y
# se pierde la sesion de la cuenta demo). Deja out/raw/pixel-10-pro/*.png y el
# manifest.json que despues leen `goldie frame|manifest|studio`.
#
# Requisitos: emulador HomeSync_Pixel_9_Pro (1280x2856) arrancado, app con la
# sesion de Sofi iniciada y en el idioma que se quiere capturar.
# Uso: bash goldie/capture.sh
set -e
cd "$(dirname "$0")"
A="$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe"
RAW="out/raw/pixel-10-pro"
mkdir -p "$RAW"

# Barra de estado prolija: 9:41, bateria llena, wifi y señal completas.
"$A" shell settings put global sysui_demo_allowed 1
demo() { "$A" shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null; }
demo enter
demo clock -e hhmm 0941
demo battery -e level 100 -e plugged false
demo network -e wifi show -e level 4 -e fully true
demo network -e mobile hide
demo network -e airplane hide
demo notifications -e visible false

# Barra inferior de 4 destinos + boton central (+) en modo pareja (1280x2856):
# Inicio (160), Tareas (400), [+] (640), Finanzas (880), Compras (1120).
TAB_Y=2681
tab() { "$A" shell input tap "$1" $TAB_Y; sleep 3; }
top() { for _ in 1 2 3; do "$A" shell input swipe 640 900 640 2300 250; done; sleep 1.5; }
shot() { "$A" exec-out screencap -p > "$RAW/$1.png"; echo "  $1"; }

tab 160;  top; shot home        # Inicio (escena de pareja, cuentas, tareas y movimientos)
tab 400;  top; shot tasks       # Tareas (incluye resumen semanal "En casa, en equipo")
tab 880;  "$A" shell input tap 259 523; sleep 2; top; shot finance   # Finanzas > Movimientos
tab 1120; top; shot shopping    # Compras
tab 160;  top; "$A" shell input tap 640 420; sleep 2; shot couple    # Planes y album de pareja (sheet desde bienvenida)
"$A" shell input keyevent 4; sleep 1
tab 640;  sleep 2; shot proposals                                    # Boton central (+): gasto, tarea, notita, planes
"$A" shell input keyevent 4; sleep 1

demo exit

ABS="$(cd "$RAW" && pwd -W 2>/dev/null || pwd)"
cat > "$RAW/manifest.json" <<EOF
{
  "device": "pixel-10-pro",
  "udid": "emulator-5554",
  "capturedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "screenshots": [
    { "sceneId": "couple", "file": "$ABS/couple.png" },
    { "sceneId": "home", "file": "$ABS/home.png" },
    { "sceneId": "finance", "file": "$ABS/finance.png" },
    { "sceneId": "tasks", "file": "$ABS/tasks.png" },
    { "sceneId": "shopping", "file": "$ABS/shopping.png" },
    { "sceneId": "proposals", "file": "$ABS/proposals.png" }
  ],
  "preview": null
}
EOF
echo "listo: $RAW"
