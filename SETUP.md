# Setup complete

Everything below was installed and configured on this machine.

## Installed

| Tool | Location |
|------|----------|
| **Supabase CLI** | `node_modules/supabase` (`npx supabase`) |
| **Web deps** | `npm install` at repo root |

## Verified

- Svelte web: `npm run check` — OK

## Run commands

```powershell
# Web app
npm run dev

# Re-run full setup on a new machine
npm run setup
```

## Supabase (you still need a cloud project)

1. Create project at [supabase.com](https://supabase.com)
2. SQL Editor → run `supabase/migrations/20260520000000_mobile_schema.sql`
3. Copy **URL** + **anon key** into root `.env` as `PUBLIC_SUPABASE_URL` and `PUBLIC_SUPABASE_ANON_KEY`

