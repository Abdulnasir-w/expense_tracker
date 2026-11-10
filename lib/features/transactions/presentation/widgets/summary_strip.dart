import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class SummaryStrip extends StatelessWidget {
  final int income;
  final int expense;
  const SummaryStrip({super.key, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pal = context.palette;
    final dark = cs.brightness == Brightness.dark;
    final net = income - expense;

    Widget cell(String label, String value, Color color) => Expanded(
          child: Column(
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );

    Widget divider() =>
        Container(width: 1, height: 30, color: cs.outlineVariant);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          cell('Income', CurrencyFormatter.formatCompact(income), pal.income),
          divider(),
          cell('Expenses', CurrencyFormatter.formatCompact(expense),
              pal.expense),
          divider(),
          cell(
            'Net',
            '${net >= 0 ? '+' : '-'}${CurrencyFormatter.formatCompact(net.abs())}',
            net >= 0 ? cs.onSurface : pal.expense,
          ),
        ],
      ),
    );
  }
}
