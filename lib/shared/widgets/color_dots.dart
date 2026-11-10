import 'package:flutter/material.dart';

class ColorDots extends StatelessWidget {
  const ColorDots({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in colors)
          GestureDetector(
            onTap: () => onSelect(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: c == selected ? cs.onSurface : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: c == selected
                  ? const Icon(Icons.check_rounded,
                      size: 18, color: Colors.white)
                  : null,
            ),
          ),
      ],
    );
  }
}
