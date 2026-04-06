# Finance Tracker App

A production-grade freelance finance tracker built with Flutter and Supabase.

## Features
- Income and expense tracking
- Client management
- Transaction ledger
- Dashboard with charts and financial summaries
- Worktree (project/task hierarchy) management
- Reports and settings

## Architecture
- **Frontend**: Flutter (cross-platform, runs as a web app on Replit)
- **Backend**: Supabase (authentication + PostgreSQL database)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Charts**: fl_chart

## Project Structure
- `lib/core/` — Constants, router, and utility extensions
- `lib/data/` — Models and Supabase repositories
- `lib/features/` — Auth, dashboard, clients, transactions, worktree, reports, settings
- `lib/providers/` — Riverpod providers
- `lib/shared/` — Reusable UI components

## Environment Variables / Secrets
The following secrets must be set in Replit Secrets:
- `SUPABASE_URL` — Your Supabase project URL
- `SUPABASE_ANON_KEY` — Your Supabase anon/public key

These are passed to the Flutter app at build time via `--dart-define`.

## Running the App
The app runs via the "Start application" workflow:
```
flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0 \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Deployment
For static deployment, build with:
```
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```
Output goes to `build/web/`.
