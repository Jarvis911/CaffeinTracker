# Caffein Tracker — one-time setup (run from repo root)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$FlutterBin = Join-Path $Root "tools\flutter\bin"

if (-not (Test-Path (Join-Path $FlutterBin "flutter.bat"))) {
    Write-Host "Cloning Flutter SDK..."
    New-Item -ItemType Directory -Force -Path (Join-Path $Root "tools") | Out-Null
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 (Join-Path $Root "tools\flutter")
}

$env:Path = "$FlutterBin;" + $env:Path

Write-Host "Flutter version:"
flutter --version

Write-Host "`nInstalling web dependencies..."
Set-Location $Root
npm install

Write-Host "`nSetting up mobile app..."
Set-Location (Join-Path $Root "mobile\caffein_tracker")
if (-not (Test-Path "android\app\build.gradle.kts")) {
    flutter create . --project-name caffein_tracker --org com.caffeintracker --platforms=android,ios,web
}
flutter pub get
flutter analyze

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "`nCreated mobile/caffein_tracker/.env — add your Supabase URL and anon key."
}

Write-Host "`nDone! Commands:"
Write-Host "  Web:    npm run dev"
Write-Host "  Mobile: cd mobile\caffein_tracker && ..\..\tools\flutter\bin\flutter run"
Write-Host "  DB:     paste supabase/migrations/*.sql into Supabase SQL Editor"
