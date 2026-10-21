# Manual QA checklist — 12-truck scale pass

Automated coverage (`flutter test`): invoice cash/credit/partial math,
stock decrement, FIFO allocation, addPayment status walk, soft-delete dirty
protection, LWW conflict policy, signed-URL normalization, day-summary /
inventory / sales / receivables / liability / company report reconciliation,
offline dirty-flag behavior. Everything below is what automation could NOT
verify and must be checked on devices against a real Supabase project.

## 0. Prerequisites

- [ ] Migrations applied **in order 0001 → 0016, then 0018**. Could not be verified
      from the dev machine (no Supabase CLI / credentials); check with:
      `select version from supabase_migrations.schema_migrations order by 1;`
      or `supabase migration list --linked`. Watch especially the recent ones:
      0014 (invoice photo), 0015 (driver_settlements), 0016 (updated_at + LWW
      triggers), and 0018 (driver_locations for Live Map).
- [ ] Migration **0017 (device_tokens) is intentionally NOT applied** while
      push is dormant (`kPushEnabled=false`) — its absence is NOT a defect.
      Apply it only as part of push reactivation
      (`docs/push-reactivation.md`).
- [ ] Test-scale seed applied: `supabase/seed/seed_12_trucks.sql` (SQL editor,
      test project only). Verify: 12 trucks, 12 `driverNN@demo.local` accounts,
      180 customers, 20 products / 4 categories,
      initial stock 50 per product per truck.
- [ ] Demo accounts still log in: office@demo.local / driver@demo.local.

## 1. Device matrix

| # | Device | OS | Role | Notes |
|---|---|---|---|---|
| 1 | Android phone (low-end, ~2GB) | Android 8–10 | driver | primary field profile |
| 2 | Android phone (recent) | Android 13+ | driver | POST_NOTIFICATIONS behavior |
| 3 | iPhone | latest iOS | driver | camera/photo permissions differ |
| 4 | Android tablet or wide window | any | office | responsive report layouts |
| 5 | Office desktop (web/macOS if used) | — | office | wide-screen dashboards, exports |

## 2. Login & roles

- [ ] Driver login → driver dashboard; office login → office dashboard.
- [ ] Driver cannot reach office routes (deep link `/dashboard/office`), and
      vice versa.
- [ ] Wrong password → bilingual error; logout returns to login.
- [ ] Language toggle EN ↔ دری persists across restart on both roles.

## 3. Multi-driver isolation (needs ≥2 driver devices)

- [ ] Driver 01 sees only their 15 customers and their truck's stock; Driver 02
      sees theirs. No bleed-through after both sync.
- [ ] Two drivers create invoices at the same minute → both appear in office
      dashboard; invoice numbers unique (different plate prefixes).
- [ ] Office "Today by driver" shows both drivers with correct sold/collected.

## 4. Offline-first (highest risk)

- [ ] Airplane mode ON → create cash invoice, credit invoice, partial invoice,
      general payment, attach invoice photo, mark customer visited.
      All succeed; sync bar shows "N unsynced".
- [ ] Airplane mode OFF → force sync → dirty count reaches 0; verify in
      Supabase: invoices/items/payments rows exist ONCE (no duplicates),
      invoice_items.total computed server-side, photo uploaded to
      `invoice-photos` and `photo_url` holds an object path (not http…).
- [ ] Kill the app while offline with unsynced rows → relaunch → data still
      present, sync completes.
- [ ] Restore a long-offline device (leave one device offline a full day of
      edits) → sync → LWW: newer office edits of customers/products survive;
      the stale device's older master-data edits do NOT clobber them;
      its invoices/payments all arrive (append-only).
- [ ] Soft-delete a customer on office while a driver device is offline with
      that customer visible → driver syncs → customer disappears (no
      resurrection).

## 5. Sales & money edge cases

- [ ] Credit sale over the credit limit → orange warning + confirm dialog;
      cancel aborts, continue saves.
- [ ] Partial payment 0 or ≥ total → Save disabled with bilingual error.
- [ ] Oversell (qty > remaining) → orange warning but sale allowed; inventory
      report flags "Oversold" in red.
- [ ] Pay more than owed on an invoice → warning, allowed; invoice paid,
      surplus behaves as customer credit (auto-applies to next credit invoice
      when their page opens).
- [ ] Double-tap Save on invoice/payment/handover → exactly one row.
- [ ] Cash handover: amount 0 rejected; confirm dialog; net owed drops.
- [ ] Receipt PDF and invoice PDF render Dari text correctly (Vazirmatn), AFN
      integers, correct totals; share + print work on iOS and Android.

## 6. Office reports (12-truck data volume)

- [ ] Each report loads under ~3s with the full seed + a week of activity.
- [ ] Inventory-by-driver totals match Trucks-hub numbers for the same truck.
- [ ] Sales report (week preset) = sum of that driver's day summaries.
- [ ] Receivables grand total = Σ positive customer balances; aging buckets
      colored; tap-through opens the right customer.
- [ ] Liability: sold ≈ collected + receivables (sanity line green on
      all-time); mismatch flags orange after deliberately deleting a payment.
- [ ] Company report: prev-period ▲/▼ sensible; Day/Week/Month navigation;
      trend bars match the daily table in the Excel export.
- [ ] Every report: PDF and Excel export match on-screen filters; Excel opens
      in Excel/Google Sheets with numbers as numbers; Dari headers legible;
      filenames `{report}_{driver}_{range}`.
- [ ] Offline office → each report shows the orange offline banner with local
      data instead of erroring.

## 7. Photos & signed URLs

- [ ] Customer outside/inside photos, invoice photo, load receipt: capture
      offline → upload on sync → viewable on office device (fresh signed URL).
- [ ] A legacy row manually set to an expired signed URL still displays
      (normalization) — set one via SQL to
      `https://<proj>.supabase.co/storage/v1/object/sign/invoice-photos/<id>.jpg?token=x`
      and confirm the office viewer shows the image.
- [ ] Viewing the same photo twice within ~45 min does not re-mint a URL
      (no visible delay second time).

## 8. Realtime & notifications

- [ ] Office bell rings on driver invoice INSERT while office app is open.
- [ ] Push stays DORMANT: no permission prompt on fresh install; Profile
      toggle disabled with "Not configured on this device · در این دستگاه
      تنظیم نشده" (kPushEnabled=false). Reactivation steps live in
      `docs/push-reactivation.md`.

## 9. Scale & performance spot checks

- [ ] Customer list with 180 customers grouped by driver scrolls smoothly on
      the low-end Android device.
- [ ] Product picker search with 20 products filters instantly; category chips
      correct.
- [ ] Sync of a day's work for one driver (~30 invoices + payments) completes
      < 30s on 3G-class connection; retries/backoff visible in logs on flaky
      connection, per-table errors don't abort the run.
- [ ] Day Summary and its PDF for a 30-invoice day are correct and fast.

## 10. Regression sweep

- [ ] Route screen ordering + visited toggle still work.
- [ ] Trucks hub: info toggle, stock editor save, customers tab.
- [ ] Profile edit, change password, logout.
