#!/usr/bin/env python3
"""
Sube los iconos de compras a Supabase Storage (bucket publico `shopping-icons`).

Sube TODO lo que haya en .tmp_icons/upload/ preservando la estructura:
  upload/manifest.json          -> shopping-icons/manifest.json
  upload/products/chorizo.png   -> shopping-icons/products/chorizo.png
  ...

USO:
  # La service role key esta en: Supabase Dashboard -> Project Settings -> API
  #   -> "service_role" (secret). Es la llave maestra: NO la pegues en chats.
  # PowerShell:
  #   $env:SUPABASE_SERVICE_ROLE_KEY = "eyJ...."
  #   python .tmp_icons/upload_icons.py
  # bash:
  #   export SUPABASE_SERVICE_ROLE_KEY="eyJ...."
  #   python .tmp_icons/upload_icons.py

Hace upsert (sobrescribe si ya existe), asi que es seguro re-correrlo.
"""
import mimetypes
import os
import sys
from pathlib import Path

import requests

SUPABASE_URL = os.environ.get(
    "SUPABASE_URL", "https://tfavamqszdkoeabpyxms.supabase.co"
).rstrip("/")
KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
BUCKET = "shopping-icons"
SRC = Path(__file__).resolve().parent / "upload"

if not KEY:
    sys.exit(
        "ERROR: falta SUPABASE_SERVICE_ROLE_KEY en el entorno.\n"
        "Dashboard -> Project Settings -> API -> service_role (secret).\n"
        'PowerShell:  $env:SUPABASE_SERVICE_ROLE_KEY = "eyJ..."'
    )

if not SRC.exists():
    sys.exit(f"No existe la carpeta de subida: {SRC}")

files = sorted(p for p in SRC.rglob("*") if p.is_file())
if not files:
    sys.exit(f"No hay archivos para subir en {SRC}")

print(f"Subiendo {len(files)} archivo(s) al bucket '{BUCKET}'...\n")
errors = 0
for p in files:
    rel = p.relative_to(SRC).as_posix()
    ctype = mimetypes.guess_type(p.name)[0] or "application/octet-stream"
    url = f"{SUPABASE_URL}/storage/v1/object/{BUCKET}/{rel}"
    data = p.read_bytes()
    r = requests.post(
        url,
        headers={
            "Authorization": f"Bearer {KEY}",
            "apikey": KEY,
            "Content-Type": ctype,
            "x-upsert": "true",
            "cache-control": "3600",
        },
        data=data,
        timeout=60,
    )
    ok = r.status_code in (200, 201)
    if not ok:
        errors += 1
    print(f"  {'OK ' if ok else 'ERR'} {rel}  ({ctype}) -> {r.status_code}"
          + ("" if ok else f"  {r.text[:200]}"))

print()
if errors:
    sys.exit(f"Terminado con {errors} error(es).")
print("Listo. URLs publicas:")
print(f"  manifest: {SUPABASE_URL}/storage/v1/object/public/{BUCKET}/manifest.json")
print(f"  ejemplo:  {SUPABASE_URL}/storage/v1/object/public/{BUCKET}/products/chorizo.png")
