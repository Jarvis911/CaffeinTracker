# Caffein Tracker — one-time setup (run from repo root)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

Write-Host "Installing web dependencies..."
Set-Location $Root
npm install

Write-Host "`nDone! Commands:"
Write-Host "  Web:    npm run dev"
Write-Host "  DB:     paste supabase/migrations/*.sql into Supabase SQL Editor"
