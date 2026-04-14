import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function getBearerToken(req: Request): string | null {
  const authHeader = req.headers.get('Authorization') ?? req.headers.get('authorization')
  if (!authHeader?.startsWith('Bearer ')) return null
  return authHeader.slice('Bearer '.length).trim()
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabaseClient = createClient(supabaseUrl, serviceRoleKey)

    const payload = await req.json()
    console.log('Notification payload received:', JSON.stringify(payload))

    // Support both direct calls (from Flutter) and Webhook calls (from SQL)
    // When called from a standard Supabase Webhook, the data is in the 'record' field.
    const { to_user_id, title, body, record, data } = payload
    const isWebhookCall = Boolean(record)

    if (!isWebhookCall) {
      const accessToken = getBearerToken(req)
      if (!accessToken) {
        return new Response(JSON.stringify({ error: 'Missing Authorization bearer token' }), {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }

      const { data: authData, error: authError } = await supabaseClient.auth.getUser(accessToken)
      if (authError || !authData.user) {
        console.error('Unauthorized send-notification request', authError)
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }
    
    const finalUserId = to_user_id || record?.user_id
    const finalTitle = title || record?.title
    const finalBody = body || record?.body

    if (!finalUserId || !finalTitle || !finalBody) {
      console.error('Missing required data:', { finalUserId, finalTitle, finalBody })
      return new Response(JSON.stringify({ error: 'Missing to_user_id, title or body' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 1. Get user tokens from public.user_fcm_tokens
    const { data: tokens, error: tokenError } = await supabaseClient
      .from('user_fcm_tokens')
      .select('token')
      .eq('user_id', finalUserId)

    if (tokenError) throw tokenError
    if (!tokens || tokens.length === 0) {
      console.log(`No tokens found for user ${finalUserId}. Skipping push notification.`);
      return new Response(JSON.stringify({ message: 'No tokens found for user' }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 2. Get Google Access Token for FCM v1
    const serviceAccountSecret = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    if (!serviceAccountSecret) {
      console.error('FIREBASE_SERVICE_ACCOUNT secret not found in Supabase.');
      return new Response(JSON.stringify({ error: 'FCM configuration missing on server.' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const serviceAccount = JSON.parse(serviceAccountSecret)
    const accessToken = await getAccessToken(serviceAccount)

    // 3. Send notifications to all registered tokens
    const fcmResults = await Promise.all(
      tokens.map(async (t) => {
        try {
          const fcmResponse = await fetch(
            `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
            {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${accessToken}`,
              },
              body: JSON.stringify({
                message: {
                  token: t.token,
                  notification: { 
                    title: finalTitle, 
                    body: finalBody 
                  },
                  data: data || {},
                  android: {
                    priority: 'high',
                    notification: {
                      sound: 'default'
                    }
                  },
                  apns: {
                    payload: {
                      aps: {
                        sound: 'default'
                      }
                    }
                  }
                },
              }),
            }
          )
          
          const result = await fcmResponse.json()
          if (!fcmResponse.ok) {
              console.error(`FCM error for token ${t.token.substring(0, 10)}...:`, JSON.stringify(result));
              
              // If the token is invalid or expired, delete it from our DB
              if (result.error?.status === 'INVALID_ARGUMENT' || result.error?.status === 'UNREGISTERED' || result.error?.details?.[0]?.errorCode === 'INVALID_REGISTRATION_TOKEN') {
                  console.log(`Removing invalid token: ${t.token.substring(0, 10)}...`);
                  await supabaseClient.from('user_fcm_tokens').delete().eq('token', t.token);
              }
          }
          return result
        } catch (e) {
          console.error('Error sending single notification:', e)
          return { error: e.message }
        }
      })
    )

    console.log(`Sent ${tokens.length} push notifications for user ${finalUserId}`);

    return new Response(JSON.stringify({ results: fcmResults }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    console.error('Edge Function Error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})

/**
 * Generates a Google OAuth2 access token for the Firebase Cloud Messaging API v1.
 */
async function getAccessToken(serviceAccount: any): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  const header = { alg: 'RS256', typ: 'JWT' }
  const payload = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  // 1. Encode parts
  const encode = (data: any) => btoa(JSON.stringify(data)).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '')
  const signatureInput = `${encode(header)}.${encode(payload)}`

  // 2. Import private key
  const pem = serviceAccount.private_key
  const pemHeader = '-----BEGIN PRIVATE KEY-----'
  const pemFooter = '-----END PRIVATE KEY-----'
  const pemContents = pem.substring(pem.indexOf(pemHeader) + pemHeader.length, pem.indexOf(pemFooter)).replace(/\s/g, '')
  
  const binaryDerString = atob(pemContents)
  const binaryDer = new Uint8Array(binaryDerString.length)
  for (let i = 0; i < binaryDerString.length; i++) {
    binaryDer[i] = binaryDerString.charCodeAt(i)
  }

  const key = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  // 3. Sign
  const signatureBuffer = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(signatureInput)
  )
  const signature = btoa(String.fromCharCode(...new Uint8Array(signatureBuffer))).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '')

  // 4. Exchange for access token
  const jwt = `${signatureInput}.${signature}`
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  })

  const { access_token } = await response.json()
  return access_token
}
