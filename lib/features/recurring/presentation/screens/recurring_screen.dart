import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_category_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/presentation/controllers/accounts_controller.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../domain/entities/recurring_rule_entity.dart';
import '../controllers/recurring_controller.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(recurringProvider);
    final categories = ref.watch(activeCategoriesProvider);
    final categoryMap = {for (var c in categories) c.id: c};
    final accounts = ref.watch(activeAccountsProvider);
    final accountMap = {for (var a in accounts) a.id: a};
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring & Subscriptions'),
        actions: [
          IconButton(
            tooltip: 'Run Due Bills',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () async {
              final count =
                  await ref.read(recurringProvider.notifier).processDueRules();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(count > 0
                        ? 'Successfully created $count due recurring transactions!'
                        : 'All recurring bills are up to date!'),
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Add Recurring Rule',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openRecurringSheet(
                context, ref, categories, accounts),
          ),
        ],
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (rules) {
          if (rules.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.autorenew_rounded,
                        size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
                    const SizedBox(height: 16),
                    const Text(
                      'No recurring bills or income yet',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Automate subscriptions, rent, utility bills, or monthly salaries.',
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _openRecurringSheet(
                          context, ref, categories, accounts),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Recurring Rule'),
                    ),
                  ],
                ),
              ),
            );
          }

          final activeRules = rules.where((r) => r.isActive).toList();
          final pausedRules = rules.where((r) => !r.isActive).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            children: [
              // ── Active Subscriptions & Bills ──────────────────────────────
              if (activeRules.isNotEmpty) ...[
                Text(
                  'Active Rules (${activeRules.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...activeRules.map((rule) {
                  return _RecurringTile(
                    rule: rule,
                    category: categoryMap[rule.categoryId],
                    accountName: accountMap[rule.accountId]?.name ?? 'Account',
                    onToggle: () => ref
                        .read(recurringProvider.notifier)
                        .toggleRuleActive(rule),
                    onEdit: () => _openRecurringSheet(
                        context, ref, categories, accounts,
                        existing: rule),
                    onDelete: () => ref
                        .read(recurringProvider.notifier)
                        .deleteRule(rule.id),
                  );
                }),
              ],

              // ── Paused Rules ──────────────────────────────────────────────
              if (pausedRules.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Paused (${pausedRules.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...pausedRules.map((rule) {
                  return Opacity(
                    opacity: 0.6,
                    child: _RecurringTile(
                      rule: rule,
                      category: categoryMap[rule.categoryId],
                      accountName:
                          accountMap[rule.accountId]?.name ?? 'Account',
                      onToggle: () => ref
                          .read(recurringProvider.notifier)
                          .toggleRuleActive(rule),
                      onEdit: () => _openRecurringSheet(
                          context, ref, categories, accounts,
                          existing: rule),
                      onDelete: () => ref
                          .read(recurringProvider.notifier)
                          .deleteRule(rule.id),
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _openRecurringSheet(context, ref, categories, accounts),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Recurring'),
      ),
    );
  }

  void _openRecurringSheet(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> categories,
    List<dynamic> accounts, {
    RecurringRuleEntity? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RecurringFormSheet(
        categories: categories,
        accounts: accounts,
        existing: existing,
      ),
    );
  }
}

class _RecurringTile extends StatelessWidget {
  final RecurringRuleEntity rule;
  final dynamic category;
  final String accountName;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecurringTile({
    required this.rule,
    required this.category,
    required this.accountName,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final catColor = category != null ? Color(category.colorValue) : Colors.blueGrey;
    final isExpense = rule.type == 'expense';
    final dueStr = DateFormat('MMM d, y').format(rule.nextDueDate);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: catColor.withValues(alpha: 0.18),
              child: Icon(
                AppCategoryIcons.getIcon(category?.iconKey ?? 'autorenew'),
                color: catColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rule.frequency.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due $dueStr • $accountName',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(rule.amountMinor, rule.currencyCode),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
                  ),
                ),
                Switch(
                  value: rule.isActive,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Rule')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recurring Form Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _RecurringFormSheet extends ConsumerStatefulWidget {
  final List<dynamic> categories;
  final List<dynamic> accounts;
  final RecurringRuleEntity? existing;

  const _RecurringFormSheet({
    required this.categories,
    required this.accounts,
    this.existing,
  });

  @override
  ConsumerState<_RecurringFormSheet> createState() =>
      _RecurringFormSheetState();
}

class _RecurringFormSheetState extends ConsumerState<_RecurringFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _type;
  late String _categoryId;
  late String _accountId;
  late RecurringFrequency _frequency;
  late DateTime _nextDueDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(
      text: e != null && e.amountMinor > 0
          ? (e.amountMinor / 100).toStringAsFixed(2)
          : '',
    );
    _type = e?.type ?? 'expense';
    _categoryId = e?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : '');
    _accountId = e?.accountId ??
        (widget.accounts.isNotEmpty ? widget.accounts.first.id : '');
    _frequency = e?.frequency ?? RecurringFrequency.monthly;
    _nextDueDate = e?.nextDueDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amountDouble = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final amountMinor = (amountDouble * 100).round();

    final rule = RecurringRuleEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      type: _type,
      amountMinor: amountMinor,
      currencyCode: 'USD',
      categoryId: _categoryId,
      accountId: _accountId,
      title: _titleController.text.trim(),
      frequency: _frequency,
      startDate: widget.existing?.startDate ?? DateTime.now(),
      nextDueDate: _nextDueDate,
      isActive: widget.existing?.isActive ?? true,
      autoAdd: true,
    );

    if (widget.existing != null) {
      await ref.read(recurringProvider.notifier).updateRule(rule);
    } else {
      await ref.read(recurringProvider.notifier).addRule(rule);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? 'Edit Recurring Rule' : 'New Recurring Bill / Income',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Subscription / Bill Title',
                  hintText: 'e.g. Netflix, Rent, Internet',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 12),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,10}\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Recurring Amount',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (val) {
                  final d = double.tryParse(val?.trim() ?? '');
                  if (d == null || d <= 0) return 'Please enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Frequency & Type Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(value: 'expense', child: Text('Expense')),
                        DropdownMenuItem(value: 'income', child: Text('Income')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _type = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<RecurringFrequency>(
                      initialValue: _frequency,
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      items: RecurringFrequency.values.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(f.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _frequency = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category Selector
              DropdownButtonFormField<String>(
                initialValue: _categoryId.isNotEmpty ? _categoryId : null,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: widget.categories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _categoryId = val);
                },
              ),
              const SizedBox(height: 12),

              // Account Selector
              DropdownButtonFormField<String>(
                initialValue: _accountId.isNotEmpty ? _accountId : null,
                decoration: const InputDecoration(
                  labelText: 'Charged to Account',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: widget.accounts.map((a) {
                  return DropdownMenuItem<String>(
                    value: a.id,
                    child: Text(a.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _accountId = val);
                },
              ),
              const SizedBox(height: 12),

              // Next Due Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Next Billing Date'),
                subtitle: Text(DateFormat('EEEE, MMM d, y').format(_nextDueDate)),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _nextDueDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _nextDueDate = picked);
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Save Changes' : 'Create Recurring Rule'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

