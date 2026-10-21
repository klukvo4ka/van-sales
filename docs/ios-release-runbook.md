# iOS release runbook — TestFlight distribution

The operator holds the Apple Developer account, the Supabase project and the
signing keys. Testers receive the app only through the TestFlight public link —
no App Store Connect access, no Supabase access.

## Release identity (already configured in the repo)

| Item | Value |
|---|---|
| Bundle identifier | `dev.maksimenko.vansales` |
| Display name | Van Sales Demo |
| Version | 1.0.0 (build 1) — from `pubspec.yaml` `version: 1.0.0+1` |
| App icon | branded truck icon, all sizes in `AppIcon.appiconset` (1024 has no alpha) |
| Launch screen | brand-navy `LaunchScreen.storyboard` |
| Permissions | camera + photo library + location (driver opt-in, When-In-Use minimum, background mode declared), bilingual strings in `Info.plist` |
| GPS tracking | enabled (`kGpsEnabled=true`), driver opt-in via Profile toggle; office Live Map uses keyless OpenStreetMap tiles — no billing |
| Push | dormant (`kPushEnabled=false`) — no Firebase config needed for this build |

Verified on 2026-07-10: `flutter build ios --release --no-codesign` compiles
clean (29.4 MB) with no app-owned Firebase config files present at
`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, or
`lib/firebase_options.dart`.

## Secrets

Supabase URL and publishable key are injected **only** at build time via
`--dart-define` (see `.env.example`); nothing secret is committed. The
service-role key never leaves the Supabase dashboard / CLI.

The exact release build command:

```bash
flutter build ipa \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable-key>
```

Output: `build/ios/archive/Runner.xcarchive` and
`build/ios/ipa/van_sales.ipa`.

## One-time setup

1. **Apple Developer Program** — enroll (individual or org), USD 99/year.
2. **Xcode signing** — open `ios/Runner.xcworkspace`, select the Runner
   target → Signing & Capabilities → check *Automatically manage signing*,
   pick your Team. Xcode creates the App ID `dev.maksimenko.vansales` and the
   distribution certificate/profile for you. (No push capability needed
   while dormant.)
3. **App Store Connect record** — appstoreconnect.apple.com → My Apps → “+”
   → New App: platform iOS, name *Van Sales Demo*, bundle id
   `dev.maksimenko.vansales`, SKU e.g. `van-sales-demo`.
4. **First upload** — run the build command above, then upload the IPA
   (see “Each release” step 3). Wait for processing (~10–30 min); answer
   the export-compliance question (standard HTTPS encryption only → exempt).
5. **TestFlight external group + public link** — App Store Connect →
   TestFlight → External Testing → create group *Testers* → add the build →
   fill in Beta App Information → submit for Beta App Review (first build
   only, usually < 48 h) → enable **Public Link** → send that link to
   the testers. The link stays valid across new builds assigned to the group.

## Each release

1. Bump the build number in `pubspec.yaml` (`1.0.0+1` → `1.0.0+2`; bump the
   version name too for feature releases). Commit.
2. `flutter build ipa --dart-define=... --dart-define=...` (command above).
3. Upload `build/ios/ipa/van_sales.ipa`:
   - **Transporter app** (easiest): drag the IPA in → Deliver, or
   - Xcode → Window → Organizer → Distribute App → App Store Connect.
4. In TestFlight, once processed, add the build to the *Testers* group.
   Subsequent builds in the same group generally skip re-review.
5. Testers on the public link get the update automatically in the
   TestFlight app. Nothing to re-send.

TestFlight builds expire after 90 days — ship at least one build per quarter.

## Supabase operations

- **Migrations** — apply `supabase/migrations/0001…0016` and `0018`
  (driver_locations, needed for the Live Map) in order (SQL editor or
  `supabase db push`). 0017 stays unapplied while push is dormant
  (`docs/push-reactivation.md`).
- **Accounts** — Dashboard → Authentication → Users → *Add user* (enable
  “Auto Confirm User”): email + password, and set **User Metadata**:
  ```json
  { "full_name": "Ahmad Karimi", "role": "driver" }
  ```
  `role` is `driver`, `office`, or `admin`. The `handle_new_user` trigger
  creates the `driver_profiles` row; then assign the driver a truck
  (Dashboard → table `driver_profiles` → set `truck_id`).
- **Key rotation** — Dashboard → Settings → API: rotate the publishable key,
  then rebuild + re-upload the app with the new `--dart-define` value
  (old builds stop working — coordinate with the testers).
- **Backups** — Dashboard → Database → Backups (daily on paid plans);
  before risky changes run a manual `pg_dump` via
  `supabase db dump -f backup.sql`.
- **Storage** — buckets `load-receipts`, `customer-photos`, `invoice-photos`
  are private; the app mints signed URLs itself. No action needed.

## Rollback

A bad build: remove it from the TestFlight group and re-assign the previous
build (builds remain available until they expire). Data problems: restore
from a Supabase backup — the app is offline-first, so devices re-sync.
