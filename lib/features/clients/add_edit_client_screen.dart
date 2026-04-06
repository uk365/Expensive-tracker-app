import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/client_repository.dart';
import '../../providers/client_provider.dart';
import '../../core/constants/app_constants.dart';

class AddEditClientScreen extends ConsumerStatefulWidget {
  final String? clientId;

  const AddEditClientScreen({super.key, this.clientId});

  @override
  ConsumerState<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends ConsumerState<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _businessTypeCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _status = 'active';
  String _tier = 'standard';
  String _paymentTerms = 'net30';
  String _currency = 'USD';
  String _avatarColor = '#6366F1';
  bool _loading = false;
  bool _initialized = false;

  bool get _isEditing => widget.clientId != null;

  @override
  void dispose() {
    for (final c in [
      _displayNameCtrl, _fullNameCtrl, _businessNameCtrl, _businessTypeCtrl,
      _industryCtrl, _emailCtrl, _phoneCtrl, _websiteCtrl,
      _address1Ctrl, _address2Ctrl, _cityCtrl, _stateCtrl,
      _postalCtrl, _countryCtrl, _taxIdCtrl, _notesCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _initFromClient() {
    if (_initialized || !_isEditing) return;
    final client = ref.read(clientDetailProvider(widget.clientId!)).value;
    if (client == null) return;
    _initialized = true;
    _displayNameCtrl.text = client.displayName;
    _fullNameCtrl.text = client.fullName;
    _businessNameCtrl.text = client.businessName ?? '';
    _businessTypeCtrl.text = client.businessType ?? '';
    _industryCtrl.text = client.industry ?? '';
    _emailCtrl.text = client.email ?? '';
    _phoneCtrl.text = client.phone ?? '';
    _websiteCtrl.text = client.website ?? '';
    _address1Ctrl.text = client.addressLine1 ?? '';
    _address2Ctrl.text = client.addressLine2 ?? '';
    _cityCtrl.text = client.city ?? '';
    _stateCtrl.text = client.state ?? '';
    _postalCtrl.text = client.postalCode ?? '';
    _countryCtrl.text = client.country ?? '';
    _taxIdCtrl.text = client.taxId ?? '';
    _notesCtrl.text = client.notes ?? '';
    _status = client.status;
    _tier = client.tier;
    _paymentTerms = client.paymentTerms;
    _currency = client.currency;
    _avatarColor = client.avatarColor;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(clientRepositoryProvider);
      final data = {
        'display_name': _displayNameCtrl.text.trim(),
        'full_name': _fullNameCtrl.text.trim(),
        'business_name': _businessNameCtrl.text.trim().isEmpty ? null : _businessNameCtrl.text.trim(),
        'business_type': _businessTypeCtrl.text.trim().isEmpty ? null : _businessTypeCtrl.text.trim(),
        'industry': _industryCtrl.text.trim().isEmpty ? null : _industryCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'website': _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
        'address_line1': _address1Ctrl.text.trim().isEmpty ? null : _address1Ctrl.text.trim(),
        'address_line2': _address2Ctrl.text.trim().isEmpty ? null : _address2Ctrl.text.trim(),
        'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
        'postal_code': _postalCtrl.text.trim().isEmpty ? null : _postalCtrl.text.trim(),
        'country': _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
        'tax_id': _taxIdCtrl.text.trim().isEmpty ? null : _taxIdCtrl.text.trim(),
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        'status': _status,
        'tier': _tier,
        'payment_terms': _paymentTerms,
        'currency': _currency,
        'avatar_color': _avatarColor,
      };

      if (_isEditing) {
        await repo.updateClient(widget.clientId!, data);
        ref.invalidate(clientDetailProvider(widget.clientId!));
      } else {
        final client = await repo.createClient(data);
        ref.invalidate(clientsStreamProvider);
        if (mounted) context.go('/clients/${client.id}');
        return;
      }

      ref.invalidate(clientsStreamProvider);
      if (mounted) context.pop();
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
    _initFromClient();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Client' : 'Add Client'),
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
            _sectionTitle('Identity'),
            _field(_displayNameCtrl, 'Display Name *', required: true),
            _field(_fullNameCtrl, 'Full Name *', required: true),
            _field(_businessNameCtrl, 'Business Name'),
            _field(_businessTypeCtrl, 'Business Type (LLC, Corp, etc.)'),
            _field(_industryCtrl, 'Industry'),
            const SizedBox(height: 16),
            _sectionTitle('Contact'),
            _field(_emailCtrl, 'Email', keyboard: TextInputType.emailAddress),
            _field(_phoneCtrl, 'Phone', keyboard: TextInputType.phone),
            _field(_websiteCtrl, 'Website', keyboard: TextInputType.url),
            const SizedBox(height: 16),
            _sectionTitle('Address'),
            _field(_address1Ctrl, 'Address Line 1'),
            _field(_address2Ctrl, 'Address Line 2'),
            Row(children: [
              Expanded(child: _field(_cityCtrl, 'City')),
              const SizedBox(width: 12),
              Expanded(child: _field(_stateCtrl, 'State')),
            ]),
            Row(children: [
              Expanded(child: _field(_postalCtrl, 'Postal Code')),
              const SizedBox(width: 12),
              Expanded(child: _field(_countryCtrl, 'Country')),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Relationship'),
            _dropdown('Status', _status, AppConstants.clientStatuses, (v) => setState(() => _status = v)),
            const SizedBox(height: 12),
            _dropdown('Tier', _tier, AppConstants.clientTiers, (v) => setState(() => _tier = v)),
            const SizedBox(height: 12),
            _dropdown('Payment Terms', _paymentTerms,
                ['immediate', 'net15', 'net30', 'net60'],
                (v) => setState(() => _paymentTerms = v)),
            const SizedBox(height: 12),
            _dropdown('Currency', _currency, AppConstants.supportedCurrencies,
                (v) => setState(() => _currency = v)),
            const SizedBox(height: 16),
            _sectionTitle('Financial'),
            _field(_taxIdCtrl, 'Tax ID / VAT / EIN'),
            const SizedBox(height: 16),
            _sectionTitle('Internal Notes'),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 4,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
          validator: required
              ? (v) => v?.trim().isEmpty == true ? 'Required' : null
              : null,
        ),
      );

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) =>
      DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o[0].toUpperCase() + o.substring(1)),
                ))
            .toList(),
        onChanged: (v) => onChanged(v!),
      );
}
