# 🚀 DEPLOY BACKEND NODE A INFRAESTRUCTURA REAL

## 📋 Objetivo

Desplegar el backend Node.js (que ya está codificado) a infraestructura real para staging.

**Arquitectura Target:**
```
Flutter (mobile) → Backend Node (desplegado) → Supabase (DB + Auth)
```

---

## 🎯 Check Previo: ¿Qué Tenemos?

### ✅ Backend Node Codificado

**Estructura:**
```
homeSync/
├── lib/
│   ├── application/      # Use cases, DTOs, EventBus
│   ├── domain/          # Models, engines, services, events
│   ├── infrastructure/  # Repositories, Supabase client
│   └── api/            # Routes, middleware
├── database/
│   ├── transactions.sql
│   ├── observability.sql
│   └── reconciliation*.sql
├── package.json
├── tsconfig.json
└── index.ts
```

**Dependencies:**
- Express (o similar)
- TypeScript
- Supabase client
- (Verificar en package.json)

### ✅ Migrations SQL Listas

- ✅ Schema base (users, households, tasks, ledger, etc.)
- ✅ RPC functions transaccionales
- ✅ Observabilidad (system_events, audit_logs)
- ✅ Reconciliation (integrity_checks, alerts)
- ✅ Idempotency (en código, falta tabla en DB)

### ⏳ Lo Que Falta

- ❌ **Desplegar backend Node** a plataforma real
- ❌ **Aplicar migrations SQL** a Supabase
- ❌ **Configurar variables de entorno** en el deployed backend
- ❌ **Apuntar Flutter** a la URL del backend desplegado

---

## 🏗️ PASO 1: Elegir Plataforma de Deploy

### Opciones Recomendadas

| Plataforma | Precio | Facilidad | Features | Recomendado |
|------------|--------|-----------|----------|-------------|
| **Fly.io** | ~$5-15/mes | ⭐⭐⭐⭐ | Global, Docker, Autoscaling | ✅ **SÍ** |
| **Railway** | ~$5-20/mes | ⭐⭐⭐⭐⭐ | Simple, Auto-restart | ✅ **SÍ** |
| **Render** | ~$7-25/mes | ⭐⭐⭐⭐ | Free tier limitado | ⚠️ OK |
| **VPS (DigitalOcean)** | ~$5-10/mes | ⭐⭐ | Full control | ❌ Muy trabajo |
| **Google Cloud Run** | ~$10-30/mes | ⭐⭐⭐⭐ | Serverless | ⚠️ OK |

### 🏆 Recomendación: Railway

**Por qué Railway:**
- ✅ Más fácil para empezar
- ✅ Auto-restart en crashes
- ✅ GitHub integration automática
- ✅ Preview environments
- ✅ PostgreSQL built-in (aunque usaremos Supabase)
- ✅ Free tier generoso
- ✅ Deployment automático desde GitHub

**Alternativa: Fly.io**
- ✅ Más profesional a largo plazo
- ✅ Global deployment (múltiples regiones)
- ✅ Docker-based
- ⚠️ Más configuración inicial

---

## 🚀 PASO 2: Preparar Backend para Deploy

### 2.1 Verificar package.json

```json
{
  "name": "homesync-backend",
  "version": "1.0.0",
  "main": "dist/index.js",
  "scripts": {
    "dev": "ts-node-dev index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.x.x",
    "express": "^4.x.x",
    "cors": "^2.x.x",
    "dotenv": "^16.x.x",
    // ... otras dependencias
  },
  "devDependencies": {
    "typescript": "^5.x.x",
    "@types/node": "^20.x.x",
    "@types/express": "^4.x.x",
    "ts-node-dev": "^2.x.x"
  }
}
```

**Check:**
- [ ] `main` apunta a `dist/index.js` (compiled)
- [ ] `build` script existe (`tsc`)
- [ ] `start` script existe (`node dist/index.js`)
- [ ] Dependencies están correctas
- [ ] Dev dependencies para TypeScript

### 2.2 Verificar index.ts (Entry Point)

```typescript
// index.ts
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { apiRoutes } from './lib/infrastructure/api';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/v1', apiRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
```

**Check:**
- [ ] Importa express, cors, dotenv
- [ ] Configura CORS (para permitir requests desde mobile)
- [ ] Tiene `/health` endpoint
- [ ] Usa environment variables
- [ ] Escucha en `process.env.PORT` o 3000

### 2.3 Verificar Variables de Entorno

Crear `.env.example`:

```bash
# Supabase
SUPABASE_URL=https://tfavamqszdkoeabpyxms.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# Server
NODE_ENV=production
PORT=3000

# JWT
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d

# Rate Limiting
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=60

# Idempotency
IDEMPOTENCY_EXPIRY_HOURS=24
```

**Check:**
- [ ] `.env.example` existe
- [ ] Variables necesarias están definidas
- [ ] No se sube `.env` a Git (en `.gitignore`)

### 2.4 Crear Dockerfile (Opcional pero recomendado)

```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source
COPY . .

# Build TypeScript
RUN npm run build

# Expose port
EXPOSE 3000

# Start server
CMD ["npm", "start"]
```

**Check:**
- [ ] Dockerfile existe (si usar Docker)
- [ ] Usa `node:20-alpine` (lightweight)
- [ `npm ci --only=production` (minimal dependencies)
- [ ] Copia solo lo necesario
- [ ] Expone puerto correcto

### 2.5 Verificar .gitignore

```
node_modules/
dist/
.env
.env.local
*.log
coverage/
.DS_Store
```

**Check:**
- [ ] `node_modules/` ignorado
- [ ] `dist/` ignorado (o incluido según estrategia)
- [ ] `.env` ignorado
- [ ] Logs ignorados

---

## 🔧 PASO 3: Aplicar Migrations a Supabase

### 3.1 Crear Migration Organizada

Crear `database/migrations/001_initial_schema.sql`:

```sql
-- ============================================
-- INITIAL SCHEMA FOR HOMESYNC
-- ============================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Households table
CREATE TABLE IF NOT EXISTS households (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Household members
CREATE TABLE IF NOT EXISTS household_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',  -- 'owner', 'admin', 'member'
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(household_id, user_id)
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
  created_by_id UUID NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  type TEXT DEFAULT 'one_time',  -- 'one_time', 'recurring'
  difficulty TEXT DEFAULT 'medium',  -- 'easy', 'medium', 'hard'
  xp_reward INTEGER DEFAULT 0,
  coin_reward INTEGER DEFAULT 0,
  priority TEXT DEFAULT 'medium',  -- 'low', 'medium', 'high'
  status TEXT NOT NULL DEFAULT 'active',  -- 'assigned', 'active', 'in_progress', 'pending_verification', 'verified', 'rejected'
  due_at TIMESTAMPTZ,
  last_completed_at TIMESTAMPTZ,
  last_verified_by UUID REFERENCES users(id),
  next_due_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ledger entries table
CREATE TABLE IF NOT EXISTS ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  type TEXT NOT NULL,  -- 'xp_earned', 'coins_earned', 'expense_payment', 'expense_split', etc.
  amount INTEGER NOT NULL,  -- Positive for gains, negative for losses
  currency TEXT NOT NULL,  -- 'XP', 'COIN', 'EUR', etc.
  reference_id TEXT,  -- Task ID, Expense ID, etc.
  reference_type TEXT,  -- 'task_completion', 'expense', etc.
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by TEXT,
  source TEXT DEFAULT 'api'  -- 'api', 'rpc', 'admin'
);

-- Idempotency keys table
CREATE TABLE IF NOT EXISTS idempotency_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  idempotency_key UUID NOT NULL UNIQUE,
  operation TEXT NOT NULL,  -- 'complete_task', 'verify_task', etc.
  request_body JSONB,
  response_body JSONB,
  status_code INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours')
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tasks_household ON tasks(household_id);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_household ON ledger_entries(household_id);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_user ON ledger_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_reference ON ledger_entries(reference_id, reference_type);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_created_at ON ledger_entries(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_idempotency_keys_user_key ON idempotency_keys(user_id, idempotency_key);
CREATE INDEX IF NOT EXISTS idx_idempotency_keys_expires ON idempotency_keys(expires_at);
```

### 3.2 Aplicar Observabilidad (ya existe)

Copiar `database/observability.sql` completo.

### 3.3 Aplicar RPC Functions (ya existe)

Copiar `database/transactions.sql` completo.

### 3.4 Aplicar Migrations en Supabase

**Opción A: Usar Supabase Dashboard**
1. Ir a https://supabase.com/dashboard/project/tfavamqszdkoeabpyxms
2. Ir a SQL Editor
3. Ejecutar `001_initial_schema.sql`
4. Ejecutar `observability.sql`
5. Ejecutar `transactions.sql`
6. Verificar que se crean las tablas

**Opción B: Usar Supabase CLI**
```bash
# Instalar Supabase CLI
npm install -g supabase

# Login
supabase login

# Aplicar migrations
supabase db push --project-url https://tfavamqszdkoeabpyxms.supabase.co
```

### 3.5 Verificar Implementación

```sql
-- Verificar tablas
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verificar RPC functions
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION';

-- Verificar datos iniciales (debería estar vacío)
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM tasks;
SELECT COUNT(*) FROM ledger_entries;
```

**Expected Results:**
- ✅ Tablas: users, households, household_members, tasks, ledger_entries, idempotency_keys, system_events, audit_logs, alerts, integrity_checks
- ✅ RPC functions: complete_task_transaction, verify_task_transaction, reject_task_transaction, create_expense_transaction
- ✅ Todos los counts = 0 (tablas vacías)

---

## 🚀 PASO 4: Desplegar a Railway

### 4.1 Crear Cuenta en Railway

1. Ir a https://railway.app
2. Sign up con GitHub
3. Crear nuevo proyecto: "HomeSync Backend"

### 4.2 Conectar Repositorio GitHub

**Opción A: Push a GitHub (Recomendado)**

```bash
# En tu directorio homeSync
git init
git add .
git commit -m "Initial commit: Backend Node ready for deploy"

# Crear repo en GitHub
gh repo create homesync-backend --public

# Push
git remote add origin https://github.com/tu-usuario/homesync-backend.git
git branch -M main
git push -u origin main
```

**Opción B: Importar desde Railway Dashboard**

1. En Railway, click "New Project"
2. Seleccionar "Deploy from GitHub repo"
3. Elegir tu repo

### 4.3 Configurar Variables de Entorno en Railway

En Railway Dashboard → Settings → Variables:

```bash
SUPABASE_URL=https://tfavamqszdkoeabpyxms.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
NODE_ENV=production
PORT=3000
JWT_SECRET=generate_random_secret_here
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=60
IDEMPOTENCY_EXPIRY_HOURS=24
```

**Obtener las keys de Supabase:**
1. Ir a https://supabase.com/dashboard/project/tfavamqszdkoeabpyxms/settings/api
2. Copiar `anon public` key → `SUPABASE_ANON_KEY`
3. Copiar `service_role` key → `SUPABASE_SERVICE_ROLE_KEY`

### 4.4 Configurar Deployment en Railway

En Railway → Project Settings:

**Build Command:**
```bash
npm install
npm run build
```

**Start Command:**
```bash
npm start
```

**Port:**
```
3000
```

### 4.5 Deploy y Obtener URL

Railway deployará automáticamente y te dará una URL como:
- `https://homesync-backend.up.railway.app`

**Guardar esta URL** → La usarás en Flutter.

---

## 🧪 PASO 5: Verificar Deploy

### 5.1 Health Check

```bash
curl https://homesync-backend.up.railway.app/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2026-02-17T12:00:00.000Z"
}
```

### 5.2 Verificar CORS

```bash
curl -H "Origin: http://localhost" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: content-type" \
     -X OPTIONS \
     https://homesync-backend.up.railway.app/api/v1/tasks
```

**Expected Headers:**
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: content-type, authorization
```

### 5.3 Verificar Logs en Railway Dashboard

- Ir a Railway → Project → Logs
- Verificar que no hay errores
- Verificar que el servidor arrancó correctamente

---

## 📱 PASO 6: Apuntar Flutter al Backend Desplegado

Editar `flutter_client/lib/config/app_environment.dart`:

```dart
static const Environment current = Environment.staging;

static String get baseUrl {
  switch (current) {
    case Environment.local:
      return 'http://localhost:3000/api';
    case Environment.staging:
      return 'https://homesync-backend.up.railway.app/api';  // ← TU URL REAL
    case Environment.production:
      return 'https://api.homesync.com/api';
  }
}
```

### 6.1 Limpiar y Rebuild Flutter

```bash
cd flutter_client
flutter clean
flutter pub get
flutter run
```

### 6.2 Verificar Conexión desde Flutter

1. Ejecutar la app
2. Intentar hacer un request (ej: /health)
3. Verificar console logs
4. Verificar que conecta correctamente

---

## ✅ PASO 7: Ejecutar Tests de Staging

Ahora que todo está desplegado y conectado, ejecutar los tests del checklist:

**Archivo de referencia:** `STAGING_DEPLOY_CHECKLIST.md`

### Test 1: Health Check
- [ ] `/health` responde 200
- [ ] Response es correcta
- [ ] Logs muestran request

### Test 2: Auth Flow (si está implementado)
- [ ] Login funciona
- [ ] Refresh funciona
- [ ] Logout funciona

### Test 3: Idempotencia
- [ ] Doble tap funciona
- [ ] No duplica
- [ ] Headers correctos

### Test 4: Rate Limiting
- [ ] 429 funciona
- [ ] Headers correctos
- [ ] UX informada

### Test 5: Observabilidad
- [ ] Logs estructurados
- [ ] Request ID tracking
- [ ] Audit logs funcionan

---

## 📊 Checklist Completo de Deployment

### Backend Node
- [ ] package.json verificado
- [ ] index.ts verificado
- [ ] Variables de entorno configuradas
- [ ] Dockerfile creado (opcional)
- [ ] .gitignore verificado
- [ ] Push a GitHub
- [ ] Railway configurado
- [ ] Variables de entorno en Railway
- [ ] Deploy exitoso
- [ ] URL obtenida

### Supabase
- [ ] migrations aplicadas
- [ ] Tablas creadas
- [ ] RPC functions aplicadas
- [ ] Observabilidad aplicada
- [ ] Índices creados
- [ ] Verificación SQL exitosa

### Flutter
- [ ] Apuntado a backend real
- [ ] flutter clean ejecutado
- [ ] flutter pub get ejecutado
- [ ] flutter run exitoso
- [ ] Conexión verificada

### Tests
- [ ] Test 1: Health check ✅
- [ ] Test 2: Auth flow ✅
- [ ] Test 3: Idempotencia ✅
- [ ] Test 4: Rate limiting ✅
- [ ] Test 5: Observabilidad ✅

---

## 🚨 Troubleshooting

### Issue: Deploy falla en Railway

**Causas comunes:**
- package.json incorrecto
- Falta `build` script
- Falta `start` script
- Dependencias no instaladas

**Solución:**
- Verificar package.json
- Verificar logs en Railway
- Corregir y hacer push

### Issue: Backend no conecta a Supabase

**Causas comunes:**
- Keys incorrectas
- URL incorrecta
- CORS issues

**Solución:**
- Verificar variables de entorno
- Verificar URL de Supabase
- Verificar que migrations están aplicadas

### Issue: Flutter no conecta a backend

**Causas comunes:**
- URL incorrecta
- CORS no configurado
- Backend caído

**Solución:**
- Verificar URL en app_environment.dart
- Verificar CORS en backend
- Verificar health endpoint con curl

---

## 🎯 Criterios de Éxito

El deployment es exitoso si:

1. **✅ Backend desplegado**
   - Responde `/health` correctamente
   - Logs sin errores
   - URL pública funciona

2. **✅ Supabase conectado**
   - Migrations aplicadas
   - RPC functions funcionan
   - Backend puede leer/escribir

3. **✅ Flutter conectado**
   - App hace requests
   - Responses llegan
   - Console logs correctos

4. **✅ Tests de staging pasan**
   - Auth flow funciona
   - Idempotencia funciona
   - Rate limiting funciona
   - Observabilidad funciona

---

## 🚀 Próximos Pasos

Después de staging exitoso:

1. **Implementar Retry con Exponential Backoff**
   - En Flutter
   - En backend

2. **Agregar Queue Offline Mínima**
   - Cache local en Flutter
   - Reintentos automáticos

3. **Preparar Producción**
   - Configurar dominio real
   - Configurar SSL
   - Configurar monitoring
   - Configurar alerts

---

## ✅ Conclusión

**Este es el camino realista para staging:**

1. ✅ Backend Node ya está codificado
2. ✅ Migrations SQL ya están listas
3. 🚀 Desplegar backend a Railway
4. 🚀 Aplicar migrations a Supabase
5. 🚀 Conectar Flutter
6. 🚀 Ejecutar tests de staging

**NO migrar a Edge Functions.**
**Preservar la arquitectura profesional.**

🚀 **VAMOS A DESPLEGAR ESTO.**
