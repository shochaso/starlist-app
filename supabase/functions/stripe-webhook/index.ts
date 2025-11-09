// Status:: in-progress
// Source-of-Truth:: supabase/functions/stripe-webhook/index.ts
// Spec-State:: 確定済み（Stripe Webhook統合・plan_price保存）
// Last-Updated:: 2025-11-08

import { serve } from "std/http/server.ts";
import Stripe from "stripe";
import { createClient } from "supabase-js";
import type { SupabaseClient } from "supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Environment variables
function getEnv(key: string, required = true): string {
  const value = Deno.env.get(key);
  if (required && !value) {
    throw new Error(`Missing environment variable: ${key}`);
  }
  return value || "";
}

const STRIPE_KEY = getEnv("STRIPE_API_KEY", true);
const WEBHOOK_SECRET = getEnv("STRIPE_WEBHOOK_SECRET", true);
const SUPABASE_URL = getEnv("SUPABASE_URL", true);
const SUPABASE_SERVICE_ROLE_KEY = getEnv("SUPABASE_SERVICE_ROLE_KEY", true);

const stripe = new Stripe(STRIPE_KEY, { apiVersion: "2024-06-20" });

// 金額の取り出し（最小通貨単位 -> 円へ）
// Stripeは通常cent。日本円はamount_totalがそのまま円になるケースも要注意。
const asYen = (amount?: number | null): number => {
  if (amount == null) return 0;
  // 日本円の場合、amount_totalがそのまま円の場合もあるため、100で割るかどうかは実値で確認
  // デフォルトはcent単位と仮定して/100
  return Math.round(amount / 100);
};

// 保存ヘルパー
const savePlanPrice = async (
  supabase: SupabaseClient,
  subscriptionId: string,
  amountYen: number,
  currency?: string,
): Promise<void> => {
  const { error } = await supabase
    .from("subscriptions")
    .update({
      plan_price: amountYen,
      currency: (currency ?? "JPY").toUpperCase(),
    })
    .eq("subscription_id", subscriptionId);

  if (error) {
    console.error(
      `[stripe-webhook] Failed to save plan_price for ${subscriptionId}:`,
      error,
    );
    throw error;
  }
};

serve(async (req: Request): Promise<Response> => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const sig = req.headers.get("stripe-signature");
  if (!sig) {
    return new Response(
      JSON.stringify({ ok: false, error: "Missing stripe-signature header" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const body = await req.text();
  let evt: Stripe.Event;

  try {
    evt = stripe.webhooks.constructEvent(body, sig, WEBHOOK_SECRET);
  } catch (e) {
    console.error("[stripe-webhook] Webhook signature verification failed:", e);
    return new Response(
      JSON.stringify({ ok: false, error: String(e) }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const supabase: SupabaseClient = createClient(
    SUPABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY,
  );

  try {
    switch (evt.type) {
      case "checkout.session.completed": {
        const cs = evt.data.object as Stripe.Checkout.Session;
        const subId = (cs.subscription as string) ?? "";
        if (subId) {
          const jpy = asYen(cs.amount_total);
          await savePlanPrice(supabase, subId, jpy, cs.currency ?? "JPY");
        }
        break;
      }

      case "customer.subscription.updated":
      case "customer.subscription.created": {
        const sub = evt.data.object as Stripe.Subscription;
        const item = sub.items.data[0];
        if (item?.price) {
          const unit = item.price.unit_amount ?? 0;
          const jpy = asYen(unit);
          await savePlanPrice(
            supabase,
            sub.id,
            jpy,
            item.price.currency ?? "JPY",
          );
        }
        break;
      }

      case "invoice.payment_succeeded": {
        const inv = evt.data.object as Stripe.Invoice;
        const subId = inv.subscription as string;
        if (subId) {
          const jpy = asYen(inv.amount_paid ?? inv.amount_due);
          await savePlanPrice(supabase, subId, jpy, inv.currency ?? "JPY");
        }
        break;
      }

      case "charge.refunded": {
        // 返金は監査テーブルに記録（必要に応じて）
        // await supabase.from('audit_payments').insert({...})
        console.log("[stripe-webhook] Charge refunded:", evt.data.object);
        break;
      }

      default:
        // no-op for other event types
        console.log(`[stripe-webhook] Unhandled event type: ${evt.type}`);
        break;
    }

    return new Response(
      JSON.stringify({ ok: true, type: evt.type }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (e) {
    console.error(`[stripe-webhook] Error processing ${evt.type}:`, e);
    return new Response(
      JSON.stringify({ ok: false, error: String(e), type: evt.type }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
<<<<<<< HEAD


// Source-of-Truth:: supabase/functions/stripe-webhook/index.ts
// Spec-State:: 確定済み（Stripe Webhook統合・plan_price保存）
// Last-Updated:: 2025-11-08

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@14.22.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Environment variables
function getEnv(key: string, required = true): string {
  const value = Deno.env.get(key);
  if (required && !value) {
    throw new Error(`Missing environment variable: ${key}`);
  }
  return value || "";
}

const STRIPE_KEY = getEnv("STRIPE_API_KEY", true);
const WEBHOOK_SECRET = getEnv("STRIPE_WEBHOOK_SECRET", true);
const SUPABASE_URL = getEnv("SUPABASE_URL", true);
const SUPABASE_SERVICE_ROLE_KEY = getEnv("SUPABASE_SERVICE_ROLE_KEY", true);

const stripe = new Stripe(STRIPE_KEY, { apiVersion: "2024-06-20" });

// 金額の取り出し（最小通貨単位 -> 円へ）
// Stripeは通常cent。日本円はamount_totalがそのまま円になるケースも要注意。
const asYen = (amount?: number | null): number => {
  if (amount == null) return 0;
  // 日本円の場合、amount_totalがそのまま円の場合もあるため、100で割るかどうかは実値で確認
  // デフォルトはcent単位と仮定して/100
  return Math.round(amount / 100);
};

// 保存ヘルパー
const savePlanPrice = async (
  supabase: any,
  subscriptionId: string,
  amountYen: number,
  currency?: string
): Promise<void> => {
  const { error } = await supabase
    .from("subscriptions")
    .update({
      plan_price: amountYen,
      currency: (currency ?? "JPY").toUpperCase(),
    })
    .eq("subscription_id", subscriptionId);

  if (error) {
    console.error(`[stripe-webhook] Failed to save plan_price for ${subscriptionId}:`, error);
    throw error;
  }
};

serve(async (req: Request): Promise<Response> => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const sig = req.headers.get("stripe-signature");
  if (!sig) {
    return new Response(
      JSON.stringify({ ok: false, error: "Missing stripe-signature header" }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  const body = await req.text();
  let evt: Stripe.Event;

  try {
    evt = stripe.webhooks.constructEvent(body, sig, WEBHOOK_SECRET);
  } catch (e) {
    console.error("[stripe-webhook] Webhook signature verification failed:", e);
    return new Response(
      JSON.stringify({ ok: false, error: String(e) }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    switch (evt.type) {
      case "checkout.session.completed": {
        const cs = evt.data.object as Stripe.Checkout.Session;
        const subId = (cs.subscription as string) ?? "";
        if (subId) {
          const jpy = asYen(cs.amount_total);
          await savePlanPrice(supabase, subId, jpy, cs.currency ?? "JPY");
        }
        break;
      }

      case "customer.subscription.updated":
      case "customer.subscription.created": {
        const sub = evt.data.object as Stripe.Subscription;
        const item = sub.items.data[0];
        if (item?.price) {
          const unit = item.price.unit_amount ?? 0;
          const jpy = asYen(unit);
          await savePlanPrice(supabase, sub.id, jpy, item.price.currency ?? "JPY");
        }
        break;
      }

      case "invoice.payment_succeeded": {
        const inv = evt.data.object as Stripe.Invoice;
        const subId = inv.subscription as string;
        if (subId) {
          const jpy = asYen(inv.amount_paid ?? inv.amount_due);
          await savePlanPrice(supabase, subId, jpy, inv.currency ?? "JPY");
        }
        break;
      }

      case "charge.refunded": {
        // 返金は監査テーブルに記録（必要に応じて）
        // await supabase.from('audit_payments').insert({...})
        console.log("[stripe-webhook] Charge refunded:", evt.data.object);
        break;
      }

      default:
        // no-op for other event types
        console.log(`[stripe-webhook] Unhandled event type: ${evt.type}`);
        break;
    }

    return new Response(
      JSON.stringify({ ok: true, type: evt.type }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error(`[stripe-webhook] Error processing ${evt.type}:`, e);
    return new Response(
      JSON.stringify({ ok: false, error: String(e), type: evt.type }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});


=======
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
