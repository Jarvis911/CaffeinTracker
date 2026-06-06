# Caffein Tracker — Supabase (mobile backend)

Separate backend for the **Flutter mobile app** and **web Google sign-in**. The web app still stores drink logs in `localStorage`; auth links your Google account via Supabase.

## Setup

1. Create a project at [supabase.com](https://supabase.com).
2. Install CLI: `npm i -g supabase`
3. Link: `supabase link --project-ref YOUR_PROJECT_REF`
4. Apply schema:

```bash
cd supabase
supabase db push
```

Or paste `migrations/20260520000000_mobile_schema.sql` into **SQL Editor** → Run.

5. Copy **Project URL** and **anon public key** into:
   - `mobile/caffein_tracker/.env`
   - root `.env` as `PUBLIC_SUPABASE_URL` and `PUBLIC_SUPABASE_ANON_KEY` (see `.env.example`)

## Google sign-in (web)

1. **Authentication** → Providers → **Google** → Enable.
2. Create [Google OAuth credentials](https://console.cloud.google.com/apis/credentials) (Web application).
3. Add Supabase callback URL (shown on the provider page), e.g.  
   `https://YOUR_PROJECT.supabase.co/auth/v1/callback`
4. Paste Google Client ID + secret into Supabase.
5. **Authentication** → URL Configuration → Redirect URLs:
   - `http://localhost:5173/auth/callback`
   - `https://your-domain.com/auth/callback` (production)
   - `io.supabase.caffeintracker://login-callback` (Flutter mobile)

Web login page: `/login` — or **Settings** → Account.

## Tables

| Table | Purpose |
|-------|---------|
| `profiles` | User settings, caffeine limit, sugar sensitivity |
| `drink_catalog` | Reference drinks (seeded) |
| `drink_logs` | Logged drinks |
| `health_snapshots` | Sleep, HR, steps from HealthKit / Health Connect |
| `fitness_connections` | Which providers the user connected |

## Auth

Email/password signup creates a `profiles` row automatically via trigger.

## Mobile health flow

1. User grants HealthKit (iOS) or Health Connect (Android) in the app.
2. App reads metrics locally via the `health` package.
3. App upserts `health_snapshots` and `fitness_connections` to Supabase.
4. Personalization runs on-device (same rules as web) using latest snapshot + logs.

## RLS

All user tables are scoped to `auth.uid()`. Drink catalog is read-only for authenticated users.
