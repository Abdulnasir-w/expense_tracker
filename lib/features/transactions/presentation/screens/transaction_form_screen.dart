import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/hive_service.dart';
import '../../../../core/theme/app_category_icons.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../accounts/presentation/controllers/accounts_controller.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/transaction_controller.dart';

/// Single unified form screen for both Adding and Editing transactions.
class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionEntity? initialTransaction;
  final TransactionType defaultType;

  const TransactionFormScreen({
    super.key,
    this.initialTransaction,
    this.defaultType = TransactionType.expense,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  String? _categoryId;
  String? _accountId;
  String? _toAccountId; // for transfers
  late DateTime _selectedDate;
  bool _isSaving = false;
  bool _hasUserEdits = false;

  bool get _isEditMode => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initialTransaction;
    _type = init?.type ?? widget.defaultType;

    String amountText = '';
    if (init != null) {
      final major =
          CurrencyFormatter.toMajor(init.amountMinor, init.currencyCode);
      amountText =
          major % 1 == 0 ? major.toInt().toString() : major.toStringAsFixed(2);
    }

    _titleController = TextEditingController(text: init?.title ?? '');
    _amountController = TextEditingController(text: amountText);
    _noteController = TextEditingController(text: init?.note ?? '');

    _categoryId = init?.categoryId;
    _accountId = init?.accountId;
    _toAccountId = init?.toAccountId;
    _selectedDate = init?.date ?? DateTime.now();

    _titleController.addListener(_markEdited);
    _amountController.addListener(_markEdited);
    _noteController.addListener(_markEdited);
  }

  void _markEdited() {
    if (!_hasUserEdits) setState(() => _hasUserEdits = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _hasUserEdits = true;
      });
    }
  }

  void _setDate(DateTime d) {
    setState(() {
      _selectedDate = d;
      _hasUserEdits = true;
    });
  }

  String _currencyFor(List accounts) {
    for (final a in accounts) {
      if (a.id == _accountId) return a.currencyCode as String;
    }
    return 'USD';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null && _type != TransactionType.transfer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }
    if (_type == TransactionType.transfer && _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination account')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final currency = _currencyFor(ref.read(activeAccountsProvider));
    final amountMajor = double.parse(_amountController.text);
    final amountMinor = CurrencyFormatter.toMinor(amountMajor, currency);

    final now = DateTime.now();
    final entity = TransactionEntity(
      id: widget.initialTransaction?.id ?? const Uuid().v4(),
      type: _type,
      amountMinor: amountMinor,
      currencyCode: currency,
      categoryId: _categoryId ?? HiveService.defaultCategoryIdOther,
      accountId: _accountId!,
      toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
      date: _selectedDate,
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: widget.initialTransaction?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditMode) {
      await ref
          .read(transactionControllerProvider.notifier)
          .updateTransaction(entity);
    } else {
      await ref
          .read(transactionControllerProvider.notifier)
          .addTransaction(entity);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditMode ? 'Transaction updated ✓' : 'Transaction saved ✓'),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final t = widget.initialTransaction;
    if (t == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('"${t.title}" will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await ref
        .read(transactionControllerProvider.notifier)
        .deleteTransaction(t.id);
    if (!mounted) return;
    setState(() => _hasUserEdits = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted "${t.title}"')),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUserEdits) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Discard and leave?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Keep editing')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Discard')),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final dark = cs.brightness == Brightness.dark;

    final categories = ref.watch(activeCategoriesProvider);
    final accounts = ref.watch(activeAccountsProvider);

    // Default account if not selected
    if (_accountId == null && accounts.isNotEmpty) {
      _accountId = accounts.first.id;
    }

    // Filter categories matching current transaction type
    final matchingCategories = categories.where((c) {
      if (_type == TransactionType.income) {
        return c.type == CategoryType.income || c.type == CategoryType.both;
      } else if (_type == TransactionType.expense) {
        return c.type == CategoryType.expense || c.type == CategoryType.both;
      }
      return true;
    }).toList();

    // Reset category if not in available list
    if (_categoryId != null &&
        !matchingCategories.any((c) => c.id == _categoryId) &&
        _type != TransactionType.transfer) {
      _categoryId =
          matchingCategories.isNotEmpty ? matchingCategories.first.id : null;
    } else if (_categoryId == null && matchingCategories.isNotEmpty) {
      _categoryId = matchingCategories.first.id;
    }

    final typeColor = switch (_type) {
      TransactionType.income => pal.income,
      TransactionType.transfer => cs.primary,
      _ => pal.expense,
    };
    final typeContainer = switch (_type) {
      TransactionType.income => pal.incomeContainer,
      TransactionType.transfer => cs.primaryContainer,
      _ => pal.expenseContainer,
    };
    final onType =
        ThemeData.estimateBrightnessForColor(typeColor) == Brightness.dark
            ? Colors.white
            : const Color(0xFF0B1220);
    final typeLabel = switch (_type) {
      TransactionType.income => 'Income',
      TransactionType.transfer => 'Transfer',
      _ => 'Expense',
    };
    final currency = _currencyFor(accounts);

    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final isToday = _isSameDay(_selectedDate, today);
    final isYesterday = _isSameDay(_selectedDate, yesterday);
    final isCustomDate = !isToday && !isYesterday;

    return PopScope(
      canPop: !_hasUserEdits,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final navigator = Navigator.of(context);
          final discard = await _onWillPop();
          if (discard) navigator.pop();
        }
      },
      child: AppStatusBar(
        child: Scaffold(
          body: Column(
            children: [
              ScreenHeader(
                title: _isEditMode ? 'Edit transaction' : 'New transaction',
                actions: [
                  if (_isEditMode) ...[
                    HeaderAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete',
                      onTap: _delete,
                    ),
                    const SizedBox(width: 10),
                  ],
                  HeaderAction(
                    icon: Icons.close_rounded,
                    tooltip: 'Close',
                    onTap: () => Navigator.maybePop(context),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Type switcher ─────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: dark
                                ? cs.surfaceContainerLow
                                : cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              _TypePill(
                                label: 'Expense',
                                icon: Icons.north_east_rounded,
                                active: _type == TransactionType.expense,
                                fg: pal.expense,
                                bg: pal.expenseContainer,
                                onTap: () => setState(() {
                                  _type = TransactionType.expense;
                                  _hasUserEdits = true;
                                }),
                              ),
                              _TypePill(
                                label: 'Income',
                                icon: Icons.south_west_rounded,
                                active: _type == TransactionType.income,
                                fg: pal.income,
                                bg: pal.incomeContainer,
                                onTap: () => setState(() {
                                  _type = TransactionType.income;
                                  _hasUserEdits = true;
                                }),
                              ),
                              _TypePill(
                                label: 'Transfer',
                                icon: Icons.swap_horiz_rounded,
                                active: _type == TransactionType.transfer,
                                fg: cs.primary,
                                bg: cs.primaryContainer,
                                onTap: () => setState(() {
                                  _type = TransactionType.transfer;
                                  _hasUserEdits = true;
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Big amount ────────────────────────────────
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                          decoration: BoxDecoration(
                            color: typeContainer.withValues(
                                alpha: dark ? 0.55 : 1),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$typeLabel amount',
                                style: tt.labelLarge?.copyWith(
                                  color: typeColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    currency,
                                    style: tt.titleMedium?.copyWith(
                                      color: typeColor.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 220),
                                      child: TextFormField(
                                        controller: _amountController,
                                        autofocus: !_isEditMode,
                                        textAlign: TextAlign.center,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        style: tt.displayMedium?.copyWith(
                                          color: typeColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        cursorColor: typeColor,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          filled: false,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '0',
                                          hintStyle: tt.displayMedium?.copyWith(
                                            color: typeColor.withValues(
                                                alpha: 0.35),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'Enter an amount';
                                          final n = double.tryParse(v);
                                          if (n == null || n <= 0)
                                            return 'Enter a valid amount';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ── Title ─────────────────────────────────────
                        const _Label('What was it for?'),
                        TextFormField(
                          controller: _titleController,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Groceries, Salary, Rent',
                            prefixIcon: Icon(Icons.edit_outlined),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter a title'
                              : null,
                        ),
                        const SizedBox(height: 22),

                        // ── Category ──────────────────────────────────
                        if (_type != TransactionType.transfer) ...[
                          const _Label('Category'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: matchingCategories.map((c) {
                              final color = Color(c.colorValue);
                              return _Choice(
                                label: c.name,
                                icon: AppCategoryIcons.getIcon(c.iconKey),
                                color: color,
                                selected: _categoryId == c.id,
                                onTap: () => setState(() {
                                  _categoryId = c.id;
                                  _hasUserEdits = true;
                                }),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),
                        ],

                        // ── Accounts ──────────────────────────────────
                        _Label(_type == TransactionType.transfer
                            ? 'From account'
                            : 'Account'),
                        _AccountRow(
                          accounts: accounts,
                          selectedId: _accountId,
                          onSelect: (id) => setState(() {
                            _accountId = id;
                            if (_toAccountId == id) _toAccountId = null;
                            _hasUserEdits = true;
                          }),
                        ),
                        if (_type == TransactionType.transfer) ...[
                          const SizedBox(height: 16),
                          const _Label('To account'),
                          _AccountRow(
                            accounts: accounts
                                .where((a) => a.id != _accountId)
                                .toList(),
                            selectedId: _toAccountId,
                            onSelect: (id) => setState(() {
                              _toAccountId = id;
                              _hasUserEdits = true;
                            }),
                          ),
                        ],
                        const SizedBox(height: 22),

                        // ── Date ──────────────────────────────────────
                        const _Label('Date'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Choice(
                              label: 'Today',
                              icon: Icons.today_rounded,
                              color: cs.primary,
                              selected: isToday,
                              onTap: () => _setDate(DateTime.now()),
                            ),
                            _Choice(
                              label: 'Yesterday',
                              icon: Icons.history_rounded,
                              color: cs.primary,
                              selected: isYesterday,
                              onTap: () => _setDate(yesterday),
                            ),
                            _Choice(
                              label: isCustomDate
                                  ? DateFormat('d MMM yyyy')
                                      .format(_selectedDate)
                                  : 'Pick a date',
                              icon: Icons.calendar_month_rounded,
                              color: cs.primary,
                              selected: isCustomDate,
                              onTap: _pickDate,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // ── Note ──────────────────────────────────────
                        const _Label('Note (optional)'),
                        TextFormField(
                          controller: _noteController,
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Add a few details',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Pinned save bar ─────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(top: BorderSide(color: cs.outlineVariant)),
                ),
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: onType),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _isSaving
                          ? 'Saving…'
                          : (_isEditMode
                              ? 'Update $typeLabel'
                              : 'Save $typeLabel'),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: typeColor,
                      foregroundColor: onType,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── pieces ─────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      );
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.icon,
    required this.active,
    required this.fg,
    required this.bg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final Color fg;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? bg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? fg : cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active ? fg : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable pill with an icon, used for categories and dates.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : cs.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: selected ? color : cs.onSurfaceVariant),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.accounts,
    required this.selectedId,
    required this.onSelect,
  });

  final List accounts;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (accounts.isEmpty) {
      return Text('No other accounts available',
          style: TextStyle(color: cs.onSurfaceVariant));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final a in accounts)
          _Choice(
            label: a.name as String,
            icon: AppCategoryIcons.getIcon(a.iconKey as String),
            color: Color(a.colorValue as int),
            selected: selectedId == a.id,
            onTap: () => onSelect(a.id as String),
          ),
      ],
    );
  }
}
