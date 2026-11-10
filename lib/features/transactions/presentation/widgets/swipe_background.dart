import 'package:flutter/material.dart';

class SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  final IconData icon;
  final String label;
  final bool isDelete;
  const SwipeBackground({
    super.key,
    required this.alignment,
    required this.icon,
    required this.label,
    required this.isDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isDelete ? cs.errorContainer : cs.primaryContainer;
    final fg = isDelete ? cs.onErrorContainer : cs.onPrimaryContainer;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
