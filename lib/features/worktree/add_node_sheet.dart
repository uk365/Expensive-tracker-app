import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/node.dart';
import '../../data/repositories/node_repository.dart';
import '../../providers/node_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

class AddNodeSheet extends ConsumerStatefulWidget {
  final Node? parentNode;

  const AddNodeSheet({super.key, this.parentNode});

  @override
  ConsumerState<AddNodeSheet> createState() => _AddNodeSheetState();
}

class _AddNodeSheetState extends ConsumerState<AddNodeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _nodeType = 'service';
  String _icon = '📁';
  String _billingCycle = 'monthly';
  String _currency = 'USD';
  bool _loading = false;
  bool _isLeaf = false;

  static const _typeOptions = [
    ('service', '⚙️', 'Service'),
    ('subscription', '🔄', 'Subscription'),
    ('client', '👤', 'Client'),
    ('category', '📂', 'Category'),
    ('expense', '💸', 'Expense'),
    ('donation', '🎁', 'Donation'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final repo = ref.read(nodeRepositoryProvider);
      final user = ref.read(currentUserProvider);
      final parentDepth = widget.parentNode?.depth ?? -1;

      await repo.createNode({
        'parent_id': widget.parentNode?.id,
        'user_id': user!.id,
        'name': _nameCtrl.text.trim(),
        'node_type': _nodeType,
        'icon': _icon,
        'currency': _currency,
        'amount': _isLeaf && _amountCtrl.text.isNotEmpty
            ? double.tryParse(_amountCtrl.text)
            : null,
        'billing_cycle': _isLeaf ? _billingCycle : null,
        'notes': _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
        'depth': parentDepth + 1,
        'sort_order': 0,
        'status': 'active',
      });

      ref.invalidate(worktreeProvider);
      ref.invalidate(nodesProvider);
      if (mounted) Navigator.pop(context);
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
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.parentNode != null
                    ? 'Add to "${widget.parentNode!.name}"'
                    : 'Add Root Node',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              // Node type chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _typeOptions.map((opt) {
                    final (type, icon, label) = opt;
                    final selected = _nodeType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: selected,
                        label: Text('$icon $label'),
                        onSelected: (_) => setState(() {
                          _nodeType = type;
                          _icon = icon;
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isLeaf,
                onChanged: (v) => setState(() => _isLeaf = v),
                title: const Text('Has amount (leaf node)'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              if (_isLeaf) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Amount'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _billingCycle,
                        decoration: const InputDecoration(labelText: 'Cycle'),
                        items: AppConstants.billingCycles.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              AppConstants.billingCycleLabels[c] ?? c,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _billingCycle = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Node'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
