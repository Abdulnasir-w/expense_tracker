import 'package:expense_tracker/core/theme/app_category_icons.dart';
import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/shared/widgets/category_badge.dart';
import 'package:flutter/material.dart';

class TxnTile extends StatelessWidget {
  final TransactionEntity transaction;
  final String categoryName;
  final String accountLabel;
  final int? categoryColor;
  final String? categoryIconKey;
  final VoidCallback onTap;
  const TxnTile({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.accountLabel,
    required this.onTap,
    this.categoryColor,
    this.categoryIconKey,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final dark = cs.brightness == Brightness.dark;
    final t = transaction;

    final amountColor =
        t.isIncome ? pal.income : (t.isTransfer ? cs.primary : pal.expense);
    final sign = t.isIncome ? '+' : (t.isTransfer ? '' : '-');
    final badgeColor =
        categoryColor != null ? Color(categoryColor!) : amountColor;
    final subtitle = t.isTransfer
        ? 'Transfer · $accountLabel'
        : '$categoryName · $accountLabel';
    final note = (t.note ?? '').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CategoryBadge(
                  icon: AppCategoryIcons.getIcon(categoryIconKey ??
                      (t.isIncome ? 'payments' : 'category')),
                  color: badgeColor,
                  size: 46,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.notes_rounded,
                                size: 12, color: cs.outline),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.outline,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$sign${CurrencyFormatter.format(t.amountMinor, t.currencyCode)}',
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
