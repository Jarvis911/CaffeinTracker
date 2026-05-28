# Caffein Tracker

A cozy caffeine & sugar drink tracker with **personalized recommendations** from fitness/health data.

| Platform | Stack | Folder |
|----------|-------|--------|
| **Web** | Svelte 5 + SvelteKit | `/` (this repo root) |
| **Mobile** | Flutter + Supabase + HealthKit/Health Connect | `mobile/caffein_tracker/` |
| **Backend (mobile)** | Supabase Postgres + Auth | `supabase/` |

## Features

- Animated daily caffeine ring
- Drink logging with a cute, mobile-first UI
- Health-aware drink scores (sleep, heart rate, activity, time of day, sugar sensitivity)
- Fitness provider connections (demo mode + OAuth stubs)
- Profile tuning for caffeine limits and sugar sensitivity

## Tech stack

- [Svelte 5](https://svelte.dev) (runes)
- [SvelteKit 2](https://kit.svelte.dev)
- [Tailwind CSS 4](https://tailwindcss.com)
- Local persistence via `localStorage`

## Getting started (web)

```bash
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173).

## Getting started (mobile)

See [mobile/caffein_tracker/README.md](mobile/caffein_tracker/README.md) and [supabase/README.md](supabase/README.md).

## App flow

1. **Sync** — Connect a fitness provider (demo toggles mock health data).
2. **Home** — See your caffeine budget, wellness chips, and personalized drink picks.
3. **Log** — Record what you drank.
4. **You** — Adjust name, caffeine limit, and sugar sensitivity.

## Fitness integration (roadmap)

| Provider       | Web approach                          |
|----------------|----------------------------------------|
| Google Fit     | OAuth 2.0 + REST API                   |
| Fitbit         | OAuth 2.0 + Web API                  |
| Garmin         | OAuth 1.0a / Connect API               |
| Samsung Health | Partner SDK / OAuth where available    |
| Apple Health   | HealthKit via native iOS companion app |

API stubs live at `src/routes/api/fitness/[provider]/connect/+server.ts`.

## Scripts

- `npm run dev` — development server
- `npm run build` — production build
- `npm run check` — TypeScript and Svelte checks
"# CaffeinTracker" 
