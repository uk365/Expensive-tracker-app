import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/node_provider.dart';
import '../../core/constants/app_constants.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _refCtrl = TextEditingController();

  String _type = 'income';
  String _currency = 'USD';
  String _paymentMethod = 'bank_transfer';
  String _status = 'completed';
  String? _clientId;
  String? _nodeId;
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final amount = double.parse(_amountCtrl.text.trim());

      await repo.addTransaction({
        'type': _type,
        'amount': amount,
        'currency': _currency,
        'description': _descCtrl.text.trim(),
        'payment_method': _paymentMethod,
        'status': _status,
        'client_id': _clientId,
        'node_id': _nodeId,
        'transaction_date': _date.toIso8601String().substring(0, 10),
        'notes': _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
        'reference_no': _refCtrl.text.isEmpty ? null : _refCtrl.text.trim(),
      });

      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(dashboardSummaryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added!')),
        );
        context.go('/transactions');
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
    final clients = ref.watch(clientsProvider);
    final nodes = ref.watch(nodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
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
            // Type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: AppConstants.transactionTypes.map((type) {
                    final selected = _type == type;
                    final color = type == 'income'
                        ? const Color(0xFF10B981)
                        : type == 'expense'
                            ? const Color(0xFFEF4444)
                            : type == 'donation'
                                ? const Color(0xFFA855F7)
                                : const Color(0xFFF59E0B);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _type = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? color.withAlpha(30) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: selected
                                  ? Border.all(color: color.withAlpha(100))
                                  : null,
                            ),
                            child: Text(
                              type[0].toUpperCase() + type.substring(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected ? color : null,
                                fontWeight: selected ? FontWeight.w700 : null,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Amount + Currency
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount *',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (v) {
                      if (v?.trim().isEmpty == true) return 'Required';
                      if (double.tryParse(v!) == null) return 'Invalid amount';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: AppConstants.supportedCurrencies.map((c) =>
                        DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description *',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Transaction Date'),
              subtitle: Text(
                '${_date.day}/${_date.month}/${_date.year}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Client
            clients.when(
              data: (list) => DropdownButtonFormField<String?>(
                value: _clientId,
                decoration: const InputDecoration(
                  labelText: 'Client (optional)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('None')),
                  ...list.map((c) => DropdownMenuItem(
                      value: c.id, child: Text(c.displayName))),
                ],
                onChanged: (v) => setState(() => _clientId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.payment_outlined),
              ),
              items: AppConstants.paymentMethods.map((m) => DropdownMenuItem(
                value: m,
                child: Text(AppConstants.paymentMethodLabels[m] ?? m),
              )).toList(),
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: AppConstants.transactionStatuses
                  .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s[0].toUpperCase() + s.substring(1))))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _refCtrl,
              decoration: const InputDecoration(
                labelText: 'Reference / Invoice # (optional)',
                prefixIcon: Icon(Icons.tag_outlined),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
