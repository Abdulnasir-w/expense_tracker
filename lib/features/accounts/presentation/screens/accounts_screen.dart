import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/shared/widgets/color_dots.dart';
import 'package:expense_tracker/shared/widgets/sheet_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/category_badge.dart';
import '../../../../shared/widgets/form_kit.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../profile/presentation/widgets/profile_form_widget.dart';
import '../../domain/entities/account_entity.dart';
import '../controllers/accounts_controller.dart';

IconData _accountIcon(AccountType type) {
  switch (type) {
    case AccountType.cash:
      return Icons.payments_rounded;
    case AccountType.bank:
      return Icons.account_balance_rounded;
    case AccountType.wallet:
      return Icons.account_balance_wallet_rounded;
    case AccountType.card:
      return Icons.credit_card_rounded;
  }
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _openSheet(BuildContext context, [AccountEntity? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AccountFormSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final accountBalances = ref.watch(accountBalancesProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;

    return AppStatusBar(
      child: Scaffold(
        body: Column(
          children: [
            ScreenHeader(
              title: 'Accounts',
              subtitle: 'Wallets and balances',
              leading: HeaderAction(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onTap: () => Navigator.maybePop(context),
              ),
              actions: [
                HeaderAction(
                  icon: Icons.add_rounded,
                  tooltip: 'Add account',
                  active: true,
                  onTap: () => _openSheet(context),
                ),
              ],
            ),
            Expanded(
              child: accountsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (accounts) {
                  final active = accounts.where((a) => !a.isArchived).toList();
                  final archived = accounts.where((a) => a.isArchived).toList();
                  final total = active.fold<int>(
                    0,
                    (sum, a) =>
                        sum + (accountBalances[a.id] ?? a.initialBalanceMinor),
                  );

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 40),
                    children: [
                      // ── Total balance hero ─────────────────────────
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: pal.heroGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  pal.heroGradient.last.withValues(alpha: 0.3),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total across accounts',
                              style: tt.labelLarge?.copyWith(
                                  color: pal.onHero.withValues(alpha: 0.8)),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(total),
                                style: tt.headlineMedium?.copyWith(
                                  color: pal.onHero,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                FilledButton.tonalIcon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        pal.onHero.withValues(alpha: 0.2),
                                    foregroundColor: pal.onHero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () =>
                                      context.push(AppRoutes.addTransfer),
                                  icon: const Icon(Icons.swap_horiz_rounded,
                                      size: 18),
                                  label: const Text('Transfer funds'),
                                ),
                                const Spacer(),
                                Text(
                                  '${active.length} active',
                                  style: tt.labelMedium?.copyWith(
                                      color:
                                          pal.onHero.withValues(alpha: 0.75)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Active accounts ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                        child: Text('Your accounts',
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ),
                      if (active.isEmpty)
                        EmptyPanel(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'No accounts yet',
                          message:
                              'Add cash, a bank account or a card to start tracking balances.',
                          actionLabel: 'Add account',
                          onAction: () => _openSheet(context),
                        )
                      else
                        for (final account in active)
                          _AccountTile(
                            account: account,
                            balanceMinor: accountBalances[account.id] ??
                                account.initialBalanceMinor,
                            onEdit: () => _openSheet(context, account),
                            onArchive: () => ref
                                .read(accountsProvider.notifier)
                                .archiveAccount(account.id),
                          ),
                      if (active.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                          child: AddRowTile(
                            label: 'Add account',
                            onTap: () => _openSheet(context),
                          ),
                        ),

                      // ── Archived ───────────────────────────────────
                      if (archived.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
                          child: Text(
                            'Archived (${archived.length})',
                            style: tt.titleSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        for (final account in archived)
                          Opacity(
                            opacity: 0.6,
                            child: _AccountTile(
                              account: account,
                              balanceMinor: accountBalances[account.id] ??
                                  account.initialBalanceMinor,
                              onEdit: () => _openSheet(context, account),
                              onArchive: () => ref
                                  .read(accountsProvider.notifier)
                                  .updateAccount(
                                      account.copyWith(isArchived: false)),
                              isArchivedList: true,
                            ),
                          ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.balanceMinor,
    required this.onEdit,
    required this.onArchive,
    this.isArchivedList = false,
  });

  final AccountEntity account;
  final int balanceMinor;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final bool isArchivedList;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final dark = cs.brightness == Brightness.dark;
    final accent = Color(account.colorValue);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.14),
            accent.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
            child: Row(
              children: [
                CategoryBadge(
                    icon: _accountIcon(account.type), color: accent, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_cap(account.type.name)} · ${account.currencyCode}',
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(
                          balanceMinor, account.currencyCode),
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: balanceMinor < 0 ? pal.expense : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Start ${CurrencyFormatter.formatCompact(account.initialBalanceMinor)}',
                      style:
                          tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      size: 20, color: cs.onSurfaceVariant),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'archive') onArchive();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(isArchivedList ? 'Unarchive' : 'Archive'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account form sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AccountFormSheet extends ConsumerStatefulWidget {
  const _AccountFormSheet({this.existing});
  final AccountEntity? existing;

  @override
  ConsumerState<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<_AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AccountType _type;
  late String _currency;
  late Color _color;

  static const _palette = [
    Color(0xFF2E7D32),
    Color(0xFF1976D2),
    Color(0xFF6A1B9A),
    Color(0xFFD84315),
    Color(0xFF00838F),
    Color(0xFF4527A0),
    Color(0xFFC2185B),
    Color(0xFF37474F),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _balanceController = TextEditingController(
      text: e != null ? formatMinorInput(e.initialBalanceMinor) : '',
    );
    _type = e?.type ?? AccountType.cash;
    _currency = e?.currencyCode ?? 'USD';
    _color = e != null ? Color(e.colorValue) : _palette.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final account = AccountEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _type,
      currencyCode: _currency,
      initialBalanceMinor: parseMinor(_balanceController.text),
      colorValue: _color.toARGB32(),
      iconKey: _type.name,
      isArchived: widget.existing?.isArchived ?? false,
    );

    if (widget.existing != null) {
      await ref.read(accountsProvider.notifier).updateAccount(account);
    } else {
      await ref.read(accountsProvider.notifier).addAccount(account);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Form(
      key: _formKey,
      child: SheetForm(
        title: isEdit ? 'Edit account' : 'New account',
        submitLabel: isEdit ? 'Save changes' : 'Create account',
        onSubmit: _submit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Account name',
                hintText: 'e.g. Cash wallet, Meezan checking',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter an account name'
                  : null,
            ),
            const SizedBox(height: 18),
            const FormLabel('Type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in AccountType.values)
                  ChoicePill(
                    label: _cap(t.name),
                    icon: _accountIcon(t),
                    color: _color,
                    selected: _type == t,
                    onTap: () => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            CurrencyField(
              code: _currency,
              onChanged: (c) => setState(() => _currency = c),
            ),
            const SizedBox(height: 14),
            MoneyField(
              controller: _balanceController,
              label: 'Starting balance',
              currencyCode: _currency,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 18),
            const FormLabel('Color'),
            ColorDots(
              colors: _palette,
              selected: _color,
              onSelect: (c) => setState(() => _color = c),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
