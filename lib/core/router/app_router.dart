import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/worktree/worktree_screen.dart';
import '../../features/clients/clients_list_screen.dart';
import '../../features/clients/client_detail_screen.dart';
import '../../features/clients/add_edit_client_screen.dart';
import '../../features/transactions/transaction_list_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../features/transactions/transaction_detail_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/profile_settings_screen.dart';
import '../../shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isAuth = user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuth && !isAuthRoute) return '/auth/login';
      if (isAuth && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/worktree',
            builder: (_, __) => const WorktreeScreen(),
          ),
          GoRoute(
            path: '/clients',
            builder: (_, __) => const ClientsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    ClientDetailScreen(clientId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => AddEditClientScreen(
                        clientId: state.pathParameters['id']!),
                  ),
                ],
              ),
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddEditClientScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/transactions',
            builder: (_, __) => const TransactionListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddTransactionScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => TransactionDetailScreen(
                    transactionId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            builder: (_, __) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (_, __) => const ProfileSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
