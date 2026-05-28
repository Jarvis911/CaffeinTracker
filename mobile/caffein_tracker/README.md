# Caffein Tracker — Flutter mobile app

Health-aware coffee & sugar drink tracker with **real** Apple Health / Health Connect integration and Supabase sync.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.24+
- Supabase project (see `../../supabase/README.md`)
- **iOS**: Xcode, physical device or simulator with Health app
- **Android**: device/emulator with [Health Connect](https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata) installed

## Setup

1. **Supabase** — run migration in `../../supabase/migrations/`, copy URL + anon key.

2. **Env file**

```bash
cp .env.example .env
# Edit SUPABASE_URL and SUPABASE_ANON_KEY
```

3. **Generate platform folders** (first time only — Flutter not run in CI here):

```bash
cd mobile/caffein_tracker
flutter create . --project-name caffein_tracker --org com.caffeintracker
flutter pub get
```

4. **Run**

```bash
flutter run
```

Without `.env`, the app runs in **offline demo mode** (local profile + health APIs still work).

## Features

| Screen | What it does |
|--------|----------------|
| **Home** | Caffeine ring + personalized drink scores |
| **Log** | Log drinks → saved to Supabase |
| **Sync** | Connect Apple Health / Health Connect, sync snapshot |
| **You** | Caffeine limit, sugar sensitivity |

## Health integration

Uses the [`health`](https://pub.dev/packages/health) package:

- **iOS** → HealthKit (`apple_health` in DB)
- **Android** → Health Connect (`health_connect` in DB)

After permission grant, the app reads steps, heart rate, sleep, activity & water, stores a `health_snapshots` row, and runs the same personalization rules as the web app.

## Project structure

```
lib/
  main.dart
  config/env.dart
  models/models.dart
  services/
    health_service.dart      # Device health APIs
    personalization_service.dart
    supabase_repository.dart
    app_controller.dart
  screens/
  widgets/
```

## Auth

Email/password via Supabase Auth. New users get a `profiles` row automatically.
