import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

type WebhookPayload = {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: Record<string, unknown>;
};

type Push = {
  userIds: string[];
  title: string;
  body: string;
  route: string;
};

const deadTokenErrors = new Set([
  "InvalidRegistration",
  "NotRegistered",
  "MismatchSenderId",
  "InvalidApnsCredential",
]);

function afn(value: unknown): string {
  const n = Number(value ?? 0);
  return `${Math.round(n)} AFN`;
}

async function officeUserIds(): Promise<string[]> {
  const { data } = await supabase
    .from("driver_profiles")
    .select("id")
    .in("role", ["office", "admin"]);
  return (data ?? []).map((r) => r.id as string);
}

async function driverForTruck(truckId: string): Promise<string[]> {
  const { data } = await supabase
    .from("driver_profiles")
    .select("id")
    .eq("truck_id", truckId);
  return (data ?? []).map((r) => r.id as string);
}

async function buildPush(payload: WebhookPayload): Promise<Push | null> {
  const record = payload.record;
  switch (payload.table) {
    case "invoices": {
      if (payload.type !== "INSERT") return null;
      return {
        userIds: await officeUserIds(),
        title: "New invoice · فاکتور جدید",
        body: `${afn(record.total_amount)} — ${
          record.invoice_number ?? ""
        }`.trim(),
        route: "invoice",
      };
    }
    case "driver_settlements": {
      if (payload.type !== "INSERT") return null;
      return {
        userIds: [record.driver_id as string],
        title: "Cash handover recorded · تحویل پول ثبت شد",
        body: afn(record.amount),
        route: "settlement",
      };
    }
    case "truck_initial_stock": {
      return {
        userIds: await driverForTruck(record.truck_id as string),
        title: "Stock updated · موجودی تغییر کرد",
        body: "Check My Stock · موجودی خود را ببینید",
        route: "stock",
      };
    }
    default:
      return null;
  }
}

async function sendFcm(tokens: string[], push: Push): Promise<number> {
  const key = Deno.env.get("FCM_SERVER_KEY");
  if (!key || tokens.length === 0) return 0;
  let sent = 0;
  for (const token of tokens) {
    const res = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `key=${key}`,
      },
      body: JSON.stringify({
        to: token,
        notification: { title: push.title, body: push.body },
        data: { route: push.route },
        priority: "high",
      }),
    });

    const body = await res.json().catch(() => null);
    const result = body?.results?.[0];
    const error = typeof result?.error === "string" ? result.error : null;

    if (res.ok && !error) {
      sent++;
    } else if (
      res.status === 404 ||
      res.status === 410 ||
      (error != null && deadTokenErrors.has(error))
    ) {
      await supabase.from("device_tokens").delete().eq("token", token);
    }
  }
  return sent;
}

Deno.serve(async (req) => {
  try {
    const payload = (await req.json()) as WebhookPayload;
    const push = await buildPush(payload);
    if (!push || push.userIds.length === 0) {
      return Response.json({ sent: 0 });
    }
    const { data } = await supabase
      .from("device_tokens")
      .select("token")
      .in("user_id", push.userIds);
    const tokens = (data ?? []).map((r) => r.token as string);
    const sent = await sendFcm(tokens, push);
    return Response.json({ sent });
  } catch (e) {
    return Response.json({ error: String(e) }, { status: 400 });
  }
});
