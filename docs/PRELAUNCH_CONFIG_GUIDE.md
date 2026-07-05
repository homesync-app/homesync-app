# Guía de configuración pre-lanzamiento — HomeSync

Todo lo que es **configuración** (consolas externas), no código. Ordenado por
urgencia. Valores reales del proyecto:

| Dato | Valor |
|---|---|
| Package Android | `com.blas.homesync` |
| Firebase project | `homesync-prod-r7-123` |
| Supabase project | `tfavamqszdkoeabpyxms` (HomeSync App) |
| Keystore release | `flutter_client/release.keystore` |

---

## 1. RevenueCat + Play Console billing ✅ VERIFICADO FUNCIONANDO (2026-06-11)

**Verificado en device (profile, Galaxy S25):** el paywall carga precios reales
desde Play (`product.priceString` → US$ 29,99 anual / US$ 2,99 mensual), el
logcat muestra `POST /v1/receipts → 200` y `Acknowledging purchase` +
`CustomerInfo updated`. **Las compras andan de punta a punta.** Los productos
(`premium_family`, `premium_household`, `premium_solo`) están Active en Play y
los Offerings de RevenueCat (`family`/`household`/`solo` + entitlement
`premium`) resuelven bien.

**Sobre el `UnknownBackendError`:** era un 404 en un endpoint secundario de
RevenueCat (`/v1/subscribers/.../workflows/...`, una feature no usada). NO
bloquea offerings ni compras — es ruido de log. No requiere acción.

**Único cuidado con el testing:** Google auto-cancela las suscripciones de
prueba tras ~6 renovaciones aceleradas. Si Premium "se apaga solo" durante QA,
es eso (no un bug). En prod con compras reales no pasa.

### Checklist de verificación (ya OK, dejar como referencia)
Si algún día el paywall apareciera vacío o sin precios, revisar en este orden:

### 1.1 Crear el producto de suscripción en Play Console
1. [Play Console](https://play.google.com/console) → app HomeSync → **Monetize →
   Products → Subscriptions**.
2. **Create subscription**. Anotá el **Product ID** exacto (ej.
   `homesync_premium_monthly`) — lo vas a necesitar idéntico en RevenueCat.
3. Agregá un **base plan** (ej. mensual), ponele precio y **Activate**.
4. El estado del producto tiene que quedar **Active**, no Draft.

> ⚠️ Play no expone los productos hasta que hay **al menos un build subido a un
> testing track** que declare el permiso de billing. Si todavía no subiste
> nada, hacé el paso 6 (testing track) ANTES de probar compras.

### 1.2 Conectar la Service Account (esto resuelve el UnknownBackendError)
El `UnknownBackendError` casi siempre es RevenueCat sin permiso para hablar con
Google Play.
1. [RevenueCat](https://app.revenuecat.com) → tu proyecto → **Project settings →
   Apps → Google Play Store**.
2. Seguí el wizard "Service Account credentials JSON": creá la service account en
   Google Cloud, descargá el JSON y subilo a RevenueCat.
3. En **Play Console → Setup → API access**, a esa service account dale permisos:
   **View financial data, orders, and cancellation survey responses** +
   **Manage orders and subscriptions**.
4. Esperá unos minutos a que Google propague los permisos.

### 1.3 Mapear el producto en RevenueCat
1. RevenueCat → **Products** → **+ New** → pegá el **mismo Product ID** del 1.1.
2. **Entitlements** → creá/usá `premium` → adjuntá ese producto.
3. **Offerings** → en el offering `default`, agregá un **package** que apunte al
   producto. (El SDK pide el offering default; si está vacío, no hay nada que
   comprar.)
4. Doc oficial del error: <https://errors.rev.cat/configuring-products>.

### 1.4 Probar con cuenta de licencia
1. Play Console → **Setup → License testing** → agregá el email de tu tester.
2. Con ese usuario, en un build del testing track, comprá Premium.
3. Verificá: la compra entra **y el entitlement se activa para todo el hogar**
   (Premium es por hogar, no por usuario — confirmá que el otro miembro también
   lo ve).
4. Confirmá que el `UnknownBackendError` **desapareció** de los logs.

- [ ] Producto Active en Play Console
- [ ] Service account conectada con permisos financieros
- [ ] Product + Entitlement + Offering default en RevenueCat
- [ ] Compra de prueba OK y error desaparecido

---

## 2. Aplicar las migraciones SQL a producción 🔴 BLOQUEANTE

Las 3 migraciones de esta sesión ya se aplicaron a la DB de prod vía MCP, pero
los archivos `.sql` están en el working tree sin commitear. Hay que versionarlas
para que el historial no quede divergente.

1. Confirmá que están en `supabase/migrations/`:
   - `20260611111034_couple_challenge_completions.sql`
   - `20260611231411_harden_qa_admin_and_avatar_storage.sql`
   - `20260611231729_complete_couple_challenge_v1.sql`
2. **Antes de pushear**, verificá que no haya divergencia (trampa conocida del
   proyecto):
   ```powershell
   supabase migration list
   supabase db push --dry-run
   ```
   Si el dry-run quiere re-aplicar algo ya aplicado, usar
   `supabase migration repair --status applied <version>` antes de pushear.
3. Commitear los `.sql` junto con el resto del cambio.

- [ ] Dry-run limpio
- [ ] Migraciones commiteadas

---

## 3. Restringir la Firebase API key en GCP 🟡 RECOMENDADO

La API key de Firebase (`AIzaSy…`) es un identificador público, pero conviene
restringirla para que no se pueda reusar desde otra app/origen.

1. [Google Cloud Console](https://console.cloud.google.com) → proyecto
   `homesync-prod-r7-123` → **APIs & Services → Credentials**.
2. Abrí la **API key** que usa la app Android (la del `google-services.json`).
3. **Application restrictions** → **Android apps** → agregá:
   - Package name: `com.blas.homesync`
   - SHA-1: el del keystore de release (ver paso 4.2 para obtenerlo).
4. **API restrictions** → **Restrict key** → dejá habilitadas solo las APIs que
   usa la app: Identity Toolkit (Firebase Auth), Token Service, Firebase
   Installations, FCM, Firebase Analytics/Crashlytics, Cloud Storage.
5. Guardá. Probá una sesión real (login + una pantalla) para confirmar que no
   rompiste nada.

- [ ] Key restringida por package + SHA-1
- [ ] APIs limitadas
- [ ] Login sigue funcionando

---

## 4. Keystore: backup + huella + limpieza 🟡 RECOMENDADO

El keystore de release es **irrecuperable**: si lo perdés, no podés volver a
publicar actualizaciones de la app nunca más.

### 4.1 Backup fuera de la máquina
1. Copiá `flutter_client/release.keystore` **y** el `key.properties` (con las
   contraseñas) a un lugar seguro fuera del disco: gestor de contraseñas con
   adjuntos, o un drive cifrado privado.
2. **No** lo subas a git (ya está en `.gitignore`).

### 4.2 Obtener el SHA-1 / SHA-256 (para el paso 3 y para Firebase)
```powershell
keytool -list -v -keystore "C:\Users\Blas_\Documents\Aplicacion de Pareja\flutter_client\release.keystore"
```
Anotá SHA-1 y SHA-256. Si usás **Play App Signing** (recomendado), el SHA real
de producción es el que muestra Play Console → **Setup → App signing** — agregá
ESE a Firebase (Project settings → tus apps → Android → Add fingerprint),
porque Google re-firma el AAB.

### 4.3 Limpieza
- Borrá keystores duplicados/viejos de la raíz (`*.old`) que no sean el de
  release vigente, para no firmar con el equivocado por error.

- [ ] Backup del keystore + key.properties fuera de la máquina
- [ ] SHA de Play App Signing agregado a Firebase
- [ ] Duplicados `.old` borrados

---

## 5. Build de release con obfuscación 🟡 RECOMENDADO

El comando de release debe pasar `--obfuscate` (hoy el AAB es decompilable):
```powershell
cd "C:\Users\Blas_\Documents\Aplicacion de Pareja\flutter_client"
shorebird release android --dart-define=APP_ENV=production --dart-define=AUTH_MODE=firebase_third_party `
  -- --obfuscate --split-debug-info=build/symbols
```
Guardá la carpeta `build/symbols` (la necesitás para desofuscar stack traces de
Crashlytics).

- [ ] Release buildeado con `--obfuscate`
- [ ] `build/symbols` guardado

---

## 6. Play Console — ficha y compliance 🔴 BLOQUEANTE

1. **Store listing**: título, descripción corta/larga, categoría.
2. **Capturas reales** del flujo actual de UI (no mockups viejos), ícono
   512×512, feature graphic.
3. **Data safety form**: declarar datos reales que recolecta la app —
   email/perfil (Firebase Auth), avatares (Storage), datos de uso
   (Analytics/Crashlytics). Tiene que coincidir con lo que el código realmente
   manda.
4. **Content rating** + target audience + declaración de anuncios.
5. **Testing track** (internal o closed) configurado con testers activos.

- [ ] Ficha completa
- [ ] Data safety coincide con el código
- [ ] Content rating + audiencia
- [ ] Testing track con testers

---

## Orden sugerido para el día del release

1. Migraciones commiteadas y dry-run limpio (§2).
2. Build de release con obfuscación (§5) → subir a testing track (§6).
3. Con el build arriba: crear/activar productos (§1.1) y probar compra (§1.4).
4. Restringir Firebase key (§3) y backup del keystore (§4) — se pueden hacer en
   paralelo.
5. Completar ficha + Data safety (§6).
6. Pre-launch report de Google y revisar Android Vitals antes del Go.
