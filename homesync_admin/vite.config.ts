import type { Plugin } from 'vite'
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

function localSupabaseProxy(mode: string): Plugin {
  const env = loadEnv(mode, process.cwd(), '')
  const supabaseUrl = env.VITE_SUPABASE_URL
  const serviceRoleKey = env.SUPABASE_SERVICE_ROLE_KEY
  const proxyPrefix = '/admin-api/supabase'

  return {
    name: 'homesync-local-supabase-proxy',
    configureServer(server) {
      server.middlewares.use(proxyPrefix, async (req, res) => {
        if (!supabaseUrl || !serviceRoleKey) {
          res.statusCode = 500
          res.setHeader('content-type', 'application/json')
          res.end(
            JSON.stringify({
              error:
                'Missing SUPABASE_SERVICE_ROLE_KEY in homesync_admin/.env.local',
            }),
          )
          return
        }

        try {
          const originalUrl = req.originalUrl ?? req.url ?? ''
          const path = originalUrl.slice(proxyPrefix.length)
          const targetUrl = `${supabaseUrl}${path}`
          const chunks: Buffer[] = []

          for await (const chunk of req) {
            chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk))
          }

          const headers = new Headers()
          for (const [name, value] of Object.entries(req.headers)) {
            if (!value) continue
            const lower = name.toLowerCase()
            if (
              lower === 'host' ||
              lower === 'connection' ||
              lower === 'content-length'
            ) {
              continue
            }
            headers.set(name, Array.isArray(value) ? value.join(',') : value)
          }
          headers.set('apikey', serviceRoleKey)
          headers.set('authorization', `Bearer ${serviceRoleKey}`)

          const upstream = await fetch(targetUrl, {
            method: req.method,
            headers,
            body:
              req.method === 'GET' || req.method === 'HEAD'
                ? undefined
                : Buffer.concat(chunks),
          })

          res.statusCode = upstream.status
          upstream.headers.forEach((value, name) => {
            if (name.toLowerCase() !== 'content-encoding') {
              res.setHeader(name, value)
            }
          })
          res.end(Buffer.from(await upstream.arrayBuffer()))
        } catch (error) {
          res.statusCode = 502
          res.setHeader('content-type', 'application/json')
          res.end(
            JSON.stringify({
              error:
                error instanceof Error
                  ? error.message
                  : 'Local Supabase proxy failed',
            }),
          )
        }
      })
    },
  }
}

// https://vite.dev/config/
export default defineConfig(({ mode }) => ({
  plugins: [react(), localSupabaseProxy(mode)],
}))
