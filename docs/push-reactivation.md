# Push notifications — reactivation checklist

**Status (2026-07-10): DORMANT.** All push code is in the repo but
gated behind a single flag, `AppConstants.kPushEnabled = false`
(`lib/core/constants/app_constants.dart`). While the flag is `false`,
`PushService.init()` returns immediately — no `Firebase.initializeApp()`, no
permission prompt, no token upsert — even if Firebase config files are present.
The Profile toggle renders disabled with "Not configured on this device ·
در این دستگاه تنظیم نشده". The in-app Realtime bell is the only
notification channel in the dormant state.

The Android google-services Gradle plugin is applied conditionally
(`android/app/build.gradle.kts`): it only activates once
`android/app/google-services.json` exists, so builds stay green while dormant.

## Turning push ON — do these in order

1. **Firebase project**
   - Create a project in the [Firebase console](https://console.firebase.google.com).
   - Add an **Android app** with package `dev.maksimenko.vansales`; download
     `google-services.json` → place at `android/app/google-services.json`.
   - Add an **iOS app** with the Runner bundle id; download
     `GoogleService-Info.plist` → add to `ios/Runner/` **via Xcode**
     (File → Add Files, target Runner).
   - Both files are gitignored — never commit them.

2. **iOS push capability**
   - In Xcode, Runner target → Signing & Capabilities → add **Push
     Notifications** (and Background Modes → Remote notifications).
   - Attach the existing `ios/Runner/Runner.entitlements` to the Runner target
     (Build Settings → Code Signing Entitlements). Switch `aps-environment`
     to `production` for release builds.
   - In Apple Developer, create an **APNs auth key** and upload it in
     Firebase console → Project settings → Cloud Messaging → Apple app.

3. **Flip the flag**
   - Set `AppConstants.kPushEnabled = true` and rebuild. On first launch the
     app requests notification permission and starts upserting device tokens.

4. **Database**
   - Apply migration `supabase/migrations/0017_device_tokens.sql`
     (creates `device_tokens` with owner-only RLS). Idempotent.

5. **Edge Function**
   - Deploy: `supabase functions deploy send-push`
   - Secret: `supabase secrets set FCM_SERVER_KEY=<key>` — the key comes from
     Firebase console → Project settings → Cloud Messaging. Secret only;
     never in git.

6. **Database Webhooks** (Supabase dashboard → Database → Webhooks), all
   HTTP POST to the `send-push` function URL with the service-role
   `Authorization: Bearer <service_role_key>` header:

   | Webhook | Table | Events | Who gets notified |
   |---|---|---|---|
   | `push-invoices` | `invoices` | INSERT | every office/admin user — "New invoice · فاکتور جدید" with amount + number, deep-links to the office dashboard |
   | `push-settlements` | `driver_settlements` | INSERT | the settling driver — "Cash handover recorded · تحویل پول ثبت شد" with amount, deep-links to Day Summary |
   | `push-stock` | `truck_initial_stock` | INSERT, UPDATE | the driver assigned to that truck — "Stock updated · موجودی تغییر کرد", deep-links to My Stock |

7. **End-to-end test**
   - Log in on two devices (one driver, one office), accept the permission
     prompt, verify a row appears in `device_tokens` per device.
   - Driver creates an invoice → office device gets a push (background it
     first to see the system notification; foreground shows a snackbar).
   - Office records a cash handover → that driver gets a push.
   - Office edits that truck's initial stock → the driver gets a push.
   - Toggle Profile → "Push notifications" off → the device's
     `device_tokens` row disappears and pushes stop; toggle on re-registers.
   - Log out → token row is removed (`PushService.unregisterDevice()` runs
     while the session is still valid).

## Rollback

Set `kPushEnabled = false` and ship — the app reverts to Realtime-bell-only
without touching the server side. Optionally disable the three webhooks in
the dashboard to stop FCM sends entirely.
