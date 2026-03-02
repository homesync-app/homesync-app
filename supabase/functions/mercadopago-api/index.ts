import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const MP_ACCESS_TOKEN = Deno.env.get('MP_ACCESS_TOKEN');
const MP_CLIENT_ID = Deno.env.get('MP_CLIENT_ID');
const MP_CLIENT_SECRET = Deno.env.get('MP_CLIENT_SECRET');
const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const method = req.method;

  // Handle OAuth Callback (GET)
  if (method === 'GET' && url.searchParams.has('code')) {
    const code = url.searchParams.get('code');
    const state = url.searchParams.get('state'); // Expecting userId here

    if (!code || !state) {
      return new Response("Missing code or state", { status: 400, headers: corsHeaders });
    }

    try {
      // Exchange code for token
      const tokenResponse = await fetch('https://api.mercadopago.com/oauth/token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          client_id: MP_CLIENT_ID!,
          client_secret: MP_CLIENT_SECRET!,
          grant_type: 'authorization_code',
          code: code,
          redirect_uri: url.origin + url.pathname,
        }),
      });

      const tokenData = await tokenResponse.json();

      if (tokenData.error) {
        return new Response(JSON.stringify(tokenData), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
      }

      // Store in DB using service role to bypass RLS for this internal sync
      const { error: dbError } = await supabase
        .from('mercadopago_connections')
        .upsert({
          user_id: state,
          mp_user_id: tokenData.user_id?.toString(),
          access_token: tokenData.access_token,
          refresh_token: tokenData.refresh_token,
          public_key: tokenData.public_key,
          live_mode: tokenData.live_mode,
          token_type: tokenData.token_type,
          expires_at: new Date(Date.now() + tokenData.expires_in * 1000).toISOString(),
          updated_at: new Date().toISOString(),
        });

      if (dbError) throw dbError;

      // Redirect back to app
      return Response.redirect('homesync://auth-complete?status=success');

    } catch (error) {
      console.error('OAuth Error:', error);
      return Response.redirect('homesync://auth-complete?status=error&message=' + encodeURIComponent(error.message));
    }
  }

  // Handle App requests and Webhooks (POST)
  if (method === 'POST') {
    try {
      const body = await req.json();
      
      // 1. Detect if it's a Mercado Pago Webhook
      if (body.type || body.topic || (body.action && body.action.includes('.'))) {
        console.log('Webhook received:', JSON.stringify(body));
        
        // Background process to handle calculations without blocking the response
        const processWebhook = async () => {
          try {
            const topic = body.type || body.topic;
            const resourceId = body.data?.id || body.id;

            if (!resourceId) return;

            // Log raw webhook
            const { data: webhookLog, error: logError } = await supabase.from('mercadopago_webhooks').insert({
              mp_id: resourceId.toString(),
              topic: topic,
              action: body.action,
              live_mode: body.live_mode,
              payload: body,
              status: 'pending'
            }).select().single();

            if (logError) {
              console.error('Error logging webhook:', logError);
              return;
            }

            let paymentData = null;

            // If it's a payment, fetch directly
            if (topic === 'payment') {
              const mpRes = await fetch(`https://api.mercadopago.com/v1/payments/${resourceId}`, {
                headers: { 'Authorization': `Bearer ${MP_ACCESS_TOKEN}` }
              });
              paymentData = await mpRes.json();
            } 
            // If it's a merchant_order, fetch it to find the payments
            else if (topic === 'merchant_order' || topic === 'orders') {
              const orderRes = await fetch(`https://api.mercadopago.com/v1/merchant_orders/${resourceId}`, {
                headers: { 'Authorization': `Bearer ${MP_ACCESS_TOKEN}` }
              });
              const orderData = await orderRes.json();
              // Find the first approved payment in the order
              if (orderData.payments && orderData.payments.length > 0) {
                paymentData = orderData.payments.find((p: any) => p.status === 'approved');
              }
            }

            if (paymentData && paymentData.status === 'approved') {
              const extRef = paymentData.external_reference;
              
              if (extRef && extRef.startsWith('settle|')) {
                const parts = extRef.split('|');
                if (parts.length === 5) {
                  const [_, householdId, debtorId, creditorId, amountStr] = parts;
                  const amount = parseFloat(amountStr);
                  
                  const { error: rpcError } = await supabase.rpc('settle_debt', {
                    p_user_id: debtorId,
                    p_household_id: householdId,
                    p_to_user_id: creditorId,
                    p_amount: amount
                  });

                  if (rpcError) {
                    console.error('Error calling settle_debt:', rpcError);
                    await supabase.from('mercadopago_webhooks')
                      .update({ status: 'error', payload: { ...body, error: rpcError.message } })
                      .eq('id', webhookLog.id);
                  } else {
                    await supabase.from('mercadopago_webhooks').update({ 
                      status: 'processed', 
                      processed_at: new Date().toISOString() 
                    }).eq('id', webhookLog.id);
                    console.log(`Debt settled for payment ${resourceId}`);
                  }
                }
              } 
              else if (extRef && extRef.startsWith('savings|')) {
                // Format: savings|householdId|goalId|userId|amount
                const parts = extRef.split('|');
                if (parts.length === 5) {
                  const [_, householdId, goalId, userId, amountStr] = parts;
                  const amount = parseFloat(amountStr);

                  // Insert contribution (Trigger in DB will update the goal current_amount)
                  const { error: saveError } = await supabase.from('savings_contributions').insert({
                    goal_id: goalId,
                    user_id: userId,
                    amount: amount,
                    note: 'Aporte vía Mercado Pago'
                  });

                  if (saveError) {
                    console.error('Error saving contribution:', saveError);
                    await supabase.from('mercadopago_webhooks')
                      .update({ status: 'error', payload: { ...body, error: saveError.message } })
                      .eq('id', webhookLog.id);
                  } else {
                    await supabase.from('mercadopago_webhooks').update({ 
                      status: 'processed', 
                      processed_at: new Date().toISOString() 
                    }).eq('id', webhookLog.id);
                    console.log(`Savings contribution recorded for goal ${goalId}`);
                  }
                }
              }
            } else {
               await supabase.from('mercadopago_webhooks')
                .update({ status: 'ignored' })
                .eq('id', webhookLog.id);
            }
          } catch (e) {
            console.error('Processing error:', e);
          }
        };

        // Trigger processing
        processWebhook();
        
        return new Response('OK', { status: 200, headers: corsHeaders });
      }

      // 2. Standard App actions
      const { action } = body;

      if (action === 'get_auth_url') {
        const { userId } = body;
        const redirectUri = url.origin + url.pathname;
        const authUrl = `https://auth.mercadopago.com.ar/authorization?client_id=${MP_CLIENT_ID}&response_type=code&platform_id=mp&state=${userId}&redirect_uri=${encodeURIComponent(redirectUri)}`;
        
        return new Response(JSON.stringify({ url: authUrl }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      if (action === 'create_preference') {
        const { title, amount, external_reference } = body;
        const response = await fetch('https://api.mercadopago.com/checkout/preferences', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            items: [{ title, quantity: 1, unit_price: amount, currency_id: 'ARS' }],
            external_reference,
            back_urls: {
              success: 'homesync://payment-success',
              failure: 'homesync://payment-failure',
              pending: 'homesync://payment-pending'
            },
            auto_return: 'approved',
            notification_url: url.origin + url.pathname
          }),
        });

        const data = await response.json();
        return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // NEW: Get user movements for suggestion (now including incomes)
      if (action === 'get_recent_movements') {
        const { userId } = body;
        
        // Find user connection
        const { data: connection, error: connError } = await supabase
          .from('mercadopago_connections')
          .select('access_token, mp_user_id')
          .eq('user_id', userId)
          .single();
        
        if (connError || !connection) {
          return new Response(JSON.stringify({ error: "User not connected to Mercado Pago" }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
        }

        const dateFrom = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString().split('.')[0] + 'Z'; // Last 48h
        
        const mpRes = await fetch(`https://api.mercadopago.com/v1/payments/search?sort=date_created&criteria=desc&range=date_created&begin_date=${dateFrom}`, {
          headers: { 'Authorization': `Bearer ${connection.access_token}` }
        });

        const payments = await mpRes.json();
        const results = (payments.results || [])
          .filter((p: any) => p.status === 'approved')
          .map((p: any) => {
            const isCollector = p.collector_id?.toString() === connection.mp_user_id;
            const isPayer = p.payer?.id?.toString() === connection.mp_user_id;
            
            // If I am the collector, it's an income (regularly)
            // unless it's a transfer between my own accounts or similar (but usually P2P transfers show you as collector)
            let type = 'expense';
            if (isCollector) type = 'income';

            // Special case for transfers
            if (p.operation_type === 'transfer' || p.operation_type === 'money_transfer') {
              type = isCollector ? 'income' : 'expense';
            }

            return {
              id: p.id,
              title: p.description || (type === 'income' ? 'Ingreso Mercado Pago' : 'Gasto Mercado Pago'),
              amount: p.transaction_amount,
              date: p.date_created,
              status: p.status,
              type: type,
              operation_type: p.operation_type,
              payer_name: p.metadata?.payer_name || p.payer?.first_name || 'Alguien'
            };
          });

        return new Response(JSON.stringify({ movements: results }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      return new Response(JSON.stringify({ message: "Action not recognized" }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    } catch (error) {
      console.error('Server Error:', error);
      return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
  }

  return new Response("Method not allowed", { status: 405, headers: corsHeaders });
})
