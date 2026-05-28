# Setup complete

Everything below was installed and configured on this machine.

## Installed

| Tool | Location |
|------|----------|
| **Flutter 3.44** (stable) | `tools/flutter/` |
| **Supabase CLI** | `node_modules/supabase` (`npx supabase`) |
| **Web deps** | `npm install` at repo root |
| **Mobile deps** | `flutter pub get` in `mobile/caffein_tracker/` |

## Verified

- Svelte web: `npm run check` — OK
- Flutter: `flutter analyze` — OK
- Flutter tests: `flutter test` — OK
- Flutter web build: `mobile/caffein_tracker/build/web` — OK

## Run commands

```powershell
# Web app
npm run dev

# Mobile (Chrome — no phone needed)
npm run mobile:run:web

# Mobile (USB device / emulator when available)
npm run mobile:run

# Re-run full setup on a new machine
npm run setup
```

## Supabase (you still need a cloud project)

1. Create project at [supabase.com](https://supabase.com)
2. SQL Editor → run `supabase/migrations/20260520000000_mobile_schema.sql`
3. Copy **URL** + **anon key** into `mobile/caffein_tracker/.env`

Until then, the mobile app runs in **demo mode** (local health APIs still work on a real device).

## Flutter PATH (optional)

Add to your user PATH:

```
D:\CaffeinTracker\tools\flutter\bin
```

Or use the npm scripts above (they use the local SDK).
