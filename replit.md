# Finance Tracker — Freelance Financial OS

A production-grade Flutter web application for tracking freelance business income, expenses, clients, and subscriptions.

## Tech Stack

- **Language**: Dart 3.8.0 / Flutter 3.32.0
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **State Management**: flutter_riverpod 2.6.1
- **Navigation**: go_router 14.8.1
- **UI**: FlexColorScheme 8.2.0, Google Fonts (Inter + JetBrains Mono)
- **Charts**: fl_chart 0.69.2
- **Target**: Web (also supports Android, iOS, Linux, macOS, Windows)

## Project Structure

```
lib/
├── main.dart                    # Entry point — Supabase init + ProviderScope
├── app.dart                     # MaterialApp.router with FlexColorScheme
├── core/
│   ├── constants/
│   │   ├── app_constants.dart   # Supabase URLs, enums, config
│   │   ├── app_colors.dart      # Brand colors, semantic colors
│   │   └── app_text_styles.dart # Typography constants
│   ├── extensions/
│   │   ├── currency_extension.dart
│   │   ├── date_extension.dart
│   │   └── num_extension.dart
│   ├── router/
│   │   └── app_router.dart      # GoRouter with auth guard
│   └── utils/
│       ├── date_helpers.dart
│       └── number_helpers.dart
├── data/
│   ├── models/
│   │   ├── profile.dart
│   │   ├── client.dart
│   │   ├── node.dart           # Worktree node
│   │   ├── transaction.dart
│   │   └── recurring_rule.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── client_repository.dart
│       ├── node_repository.dart
│       └── transaction_repository.dart
├── providers/
│   ├── supabase_provider.dart
│   ├── auth_provider.dart
│   ├── client_provider.dart
│   ├── node_provider.dart
│   └── transaction_provider.dart
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   └── widgets/ (5 sub-widgets)
│   ├── worktree/
│   │   ├── worktree_screen.dart  # Hierarchical node tree
│   │   └── add_node_sheet.dart
│   ├── clients/
│   │   ├── clients_list_screen.dart
│   │   ├── client_detail_screen.dart
│   │   └── add_edit_client_screen.dart
│   ├── transactions/
│   │   ├── transaction_list_screen.dart
│   │   ├── add_transaction_screen.dart
│   │   └── transaction_detail_screen.dart
│   ├── reports/
│   │   └── reports_screen.dart  # Donut charts, MRR, top clients
│   └── settings/
│       ├── settings_screen.dart
│       └── profile_settings_screen.dart
└── shared/
    └── widgets/
        ├── main_shell.dart       # NavigationBar shell
        ├── amount_text.dart      # JetBrains Mono currency display
        ├── client_avatar.dart
        ├── status_badge.dart
        ├── section_header.dart
        ├── empty_state.dart
        ├── loading_skeleton.dart
        └── confirm_dialog.dart
```

## Development

```bash
flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0
```

## Supabase Configuration

See `SUPABASE_SETUP.md` for the full SQL schema and configuration guide.

To add credentials:
1. Open `lib/core/constants/app_constants.dart`
2. Replace `supabaseUrl` and `supabaseAnonKey` default values
   — OR —
3. Pass via `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## Key Features

- **Dashboard**: Net balance, income/expenses bar chart, MRR/ARR, renewal alerts
- **Worktree**: Notion-style hierarchical node tree (up to 6 levels deep)
- **Clients**: Full CRUD with search, filter, and detail view with transaction history
- **Transactions**: Full ledger with period filters, type categories, and grouping
- **Reports**: Annual overview, income-by-client donut chart, expense breakdown, top clients
- **Settings**: Profile management, Supabase configuration guide, sign out

## Notes

- WebGL not available in Replit preview iframe — white screen is expected (app IS running)
- Database is empty until you connect Supabase credentials and run the SQL migration
- Auth redirect: Unauthenticated users are sent to `/auth/login`

## Deployment

Static site: `flutter build web --release` → `build/web`
