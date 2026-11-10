import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class HeroStatTile extends StatelessWidget {
  const HeroStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: pal.onHero.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: pal.onHero.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: pal.onHero),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: pal.onHero.withValues(alpha: 0.75),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: pal.onHero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
