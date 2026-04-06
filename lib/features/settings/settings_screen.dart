import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../shared/widgets/client_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile header
          profile.when(
            data: (p) => p == null
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        ClientAvatar(
                          initials: p.initials,
                          color: '#6366F1',
                          size: 56,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.fullName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                p.email,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(150),
                                ),
                              ),
                              if (p.businessName != null)
                                Text(
                                  p.businessName!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.go('/settings/profile'),
                        ),
                      ],
                    ),
                  ),
            loading: () => const SizedBox(height: 80),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),

          _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Edit your name, business, currency',
            onTap: () => context.go('/settings/profile'),
          ),

          const Divider(),
          _SectionHeader('Data & Backup'),
          _SettingsTile(
            icon: Icons.cloud_upload_outlined,
            title: 'Backup to Google Drive',
            subtitle: 'Export your data for safekeeping',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Google Drive backup — coming soon!')),
            ),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Export Data',
            subtitle: 'Download as CSV or JSON',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export — coming soon!')),
            ),
          ),

          const Divider(),
          _SectionHeader('App'),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: 'System default (dark/light)',
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Renewal alerts and reminders',
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Finance Tracker v1.0.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Finance Tracker',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Production-grade freelance finance OS',
            ),
          ),

          const Divider(),
          _SectionHeader('Supabase Setup'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.dns_outlined,
                        color: theme.colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Database Configuration',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'To connect your Supabase database, add your credentials to:\n\nlib/core/constants/app_constants.dart\n\nOr pass them as environment variables:\n• SUPABASE_URL\n• SUPABASE_ANON_KEY\n\nSee SUPABASE_SETUP.md for the full SQL migration.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final repo = AuthRepository(
                    ref.read(supabaseClientProvider));
                await repo.signOut();
                if (context.mounted) context.go('/auth/login');
              },
              icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              label: const Text('Sign Out',
                  style: TextStyle(color: Color(0xFFEF4444))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
