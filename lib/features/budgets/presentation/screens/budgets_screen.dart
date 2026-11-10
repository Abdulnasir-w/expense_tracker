import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_category_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../domain/entities/budget_entity.dart';
import '../controllers/budgets_controller.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final spentMap = ref.watch(categorySpentThisMonthProvider);
    final totalSpentThisMonth = ref.watch(totalSpentThisMonthProvider);
    final categories = ref.watch(activeCategoriesProvider);
    final categoryMap = {for (var c in categories) c.id: c};
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budgets'),
        actions: [
          IconButton(
            tooltip: 'Add Budget',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openBudgetSheet(context, ref, categories),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (budgets) {
          final totalBudgetedMinor = budgets.fold<int>(
            0,
            (sum, b) => sum + b.limitMinor,
          );
          final remainingMinor = totalBudgetedMinor - totalSpentThisMonth;
          final overallRatio = totalBudgetedMinor > 0
              ? (totalSpentThisMonth / totalBudgetedMinor).clamp(0.0, 1.0)
              : 0.0;
          final isOver = totalBudgetedMinor > 0 &&
              totalSpentThisMonth > totalBudgetedMinor;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // ── Overall Budget Overview Card ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary,
                      Color.lerp(cs.primary, Colors.black, 0.3)!
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL MONTHLY BUDGET',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isOver
                                ? AppColors.expenseRed.withValues(alpha: 0.3)
                                : AppColors.incomeGreen.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOver ? 'OVER BUDGET' : 'ON TRACK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isOver
                                  ? AppColors.expenseRed
                                  : AppColors.incomeGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(totalBudgetedMinor),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: cs.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overallRatio,
                        minHeight: 10,
                        backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOver ? AppColors.expenseRed : AppColors.incomeGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent: ${CurrencyFormatter.format(totalSpentThisMonth)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onPrimary.withValues(alpha: 0.8)),
                        ),
                        Text(
                          isOver
                              ? 'Exceeded by ${CurrencyFormatter.format(totalSpentThisMonth - totalBudgetedMinor)}'
                              : 'Remaining: ${CurrencyFormatter.format(remainingMinor)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOver ? Colors.amberAccent : cs.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Category Budgets Header ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Limits',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openBudgetSheet(context, ref, categories),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Limit'),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (budgets.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.savings_outlined,
                            size: 54,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
                        const SizedBox(height: 12),
                        const Text(
                          'No category budgets set',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set monthly spending limits for categories like Food, Bills, or Fuel.',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ...budgets.map((budget) {
                  final cat = categoryMap[budget.categoryId];
                  final catName = cat?.name ?? 'General Category';
                  final catColor =
                      cat != null ? Color(cat.colorValue) : Colors.blueGrey;
                  final spent = spentMap[budget.categoryId] ?? 0;
                  final ratio =
                      budget.limitMinor > 0 ? (spent / budget.limitMinor) : 0.0;
                  final catOver = spent > budget.limitMinor;

                  Color statusColor = AppColors.incomeGreen;
                  if (ratio >= 0.75 && ratio <= 1.0)
                    statusColor = Colors.orange;
                  if (catOver) statusColor = AppColors.expenseRed;

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: catOver
                            ? AppColors.expenseRed.withValues(alpha: 0.4)
                            : cs.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    catColor.withValues(alpha: 0.18),
                                child: Icon(
                                  AppCategoryIcons.getIcon(
                                      cat?.iconKey ?? 'category'),
                                  color: catColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      catName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      catOver
                                          ? 'Over budget by ${CurrencyFormatter.format(spent - budget.limitMinor)}'
                                          : 'Remaining: ${CurrencyFormatter.format(budget.limitMinor - spent)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: catOver
                                            ? AppColors.expenseRed
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(budget.limitMinor),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    '${(ratio * 100).toStringAsFixed(0)}% used',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _openBudgetSheet(context, ref, categories,
                                        existing: budget);
                                  }
                                  if (val == 'delete') {
                                    ref
                                        .read(budgetsProvider.notifier)
                                        .deleteBudget(budget.id);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Edit Limit')),
                                  const PopupMenuItem(
                                      value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio.clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(statusColor),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Spent: ${CurrencyFormatter.format(spent)}',
                                style: TextStyle(
                                    fontSize: 11, color: cs.onSurfaceVariant),
                              ),
                              Text(
                                'Limit: ${CurrencyFormatter.format(budget.limitMinor)}',
                                style: TextStyle(
                                    fontSize: 11, color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openBudgetSheet(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> categories, {
    BudgetEntity? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BudgetFormSheet(
        categories: categories,
        existing: existing,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget Form Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetFormSheet extends ConsumerStatefulWidget {
  final List<dynamic> categories;
  final BudgetEntity? existing;

  const _BudgetFormSheet({required this.categories, this.existing});

  @override
  ConsumerState<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<_BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _limitController = TextEditingController(
      text: e != null && e.limitMinor > 0
          ? (e.limitMinor / 100).toStringAsFixed(2)
          : '',
    );
    _categoryId = e?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final limitDouble = double.tryParse(_limitController.text.trim()) ?? 0.0;
    final limitMinor = (limitDouble * 100).round();

    final budget = BudgetEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      categoryId: _categoryId,
      limitMinor: limitMinor,
      period: BudgetPeriod.monthly,
    );

    await ref.read(budgetsProvider.notifier).setBudget(budget);
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
                isEdit ? 'Edit Category Budget' : 'Set Category Budget',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),

              // Category Selector
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Select Category',
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
              const SizedBox(height: 16),

              // Monthly Limit
              TextFormField(
                controller: _limitController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,10}\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Monthly Spending Limit',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                validator: (val) {
                  final d = double.tryParse(val?.trim() ?? '');
                  if (d == null || d <= 0)
                    return 'Please enter a valid budget limit';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Update Budget' : 'Set Budget'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
