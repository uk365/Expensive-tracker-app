import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supabase_provider.dart';
import '../../core/constants/app_constants.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  String _currency = 'USD';
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _businessCtrl.dispose();
    super.dispose();
  }

  void _initProfile() {
    if (_initialized) return;
    final profile = ref.read(profileStreamProvider).value;
    if (profile == null) return;
    _initialized = true;
    _nameCtrl.text = profile.fullName;
    _businessCtrl.text = profile.businessName ?? '';
    _currency = profile.currency;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final profile = ref.read(profileStreamProvider).value;
      if (profile == null) throw Exception('Profile not loaded');
      final repo = AuthRepository(ref.read(supabaseClientProvider));
      await repo.updateProfile(
        profile.copyWith(
          fullName: _nameCtrl.text.trim(),
          businessName: _businessCtrl.text.trim().isEmpty
              ? null
              : _businessCtrl.text.trim(),
          currency: _currency,
        ),
      );
      ref.invalidate(profileStreamProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessCtrl,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: const InputDecoration(
                labelText: 'Default Currency',
                prefixIcon: Icon(Icons.currency_exchange_outlined),
              ),
              items: AppConstants.supportedCurrencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _currency = v!),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
