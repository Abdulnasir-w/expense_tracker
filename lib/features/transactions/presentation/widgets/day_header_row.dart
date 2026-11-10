import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class DayHeaderRow extends StatelessWidget {
  const DayHeaderRow({super.key, required this.label, required this.netMinor});
  final String label;
  final int netMinor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pal = context.palette;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          if (netMinor != 0)
            Text(
              '${netMinor > 0 ? '+' : '-'}${CurrencyFormatter.formatCompact(netMinor.abs())}',
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: netMinor > 0 ? pal.income : pal.expense,
              ),
            ),
        ],
      ),
    );
  }
}
