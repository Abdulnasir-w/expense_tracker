import 'dart:math' as math;

import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/shared/widgets/screen_header.dart';

/// Four short pages. Each page shows a small, real-looking slice of the app
/// with a floating highlight, so people see what they are getting.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _PageSpec {
  const _PageSpec(this.title, this.body, this.art);
  final String title;
  final String body;
  final Widget art;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <_PageSpec>[
    _PageSpec(
      'Log a spend in seconds',
      'Tap +, enter the amount and pick a category. That is the whole routine.',
      _QuickAddArt(),
    ),
    _PageSpec(
      'See where it goes',
      'Clear charts break your spending down by category and compare it with last month.',
      _InsightsArt(),
    ),
    _PageSpec(
      'Stay within your budget',
      'Set a monthly budget and always know how much you can still spend each day.',
      _BudgetArt(),
    ),
    _PageSpec(
      'Private by design',
      'No account needed. Your records live on this phone, not on a server.',
      _PrivacyArt(),
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  void _finish() => context.go(AppRoutes.profileSetup);

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _back() => _controller.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _parallax(int i, Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, c) {
        final page =
            (_controller.hasClients && _controller.position.haveDimensions)
                ? (_controller.page ?? _index.toDouble())
                : _index.toDouble();
        final d = (page - i).clamp(-1.0, 1.0);
        return Opacity(
          opacity: 1 - d.abs() * 0.7,
          child: Transform.translate(
            offset: Offset(-d * 50, 0),
            child: Transform.scale(scale: 1 - d.abs() * 0.06, child: c),
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppStatusBar(
      child: Scaffold(
        body: Stack(
          children: [
            // soft glow behind the art
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.55),
                    radius: 0.95,
                    colors: [
                      cs.primary.withValues(alpha: 0.16),
                      cs.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    child: Row(
                      children: [
                        Visibility(
                          visible: _index > 0,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            onPressed: _back,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const Spacer(),
                        Visibility(
                          visible: !_isLast,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: TextButton(
                              onPressed: _finish, child: const Text('Skip')),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (_, i) {
                        final page = _pages[i];
                        return Column(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Center(
                                child: _parallax(
                                  i,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28),
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 340),
                                      child: _ArtFrame(child: page.art),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(28, 28, 28, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      page.title,
                                      style: tt.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      page.body,
                                      style: tt.bodyLarge?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _index ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index ? cs.primary : cs.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(_isLast ? 'Get started' : 'Continue'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── frame & badge ─────────────────────────

class _ArtFrame extends StatelessWidget {
  const _ArtFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.4 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Small tilted pill that floats over the corner of an art frame.
class _FloatBadge extends StatelessWidget {
  const _FloatBadge({
    required this.icon,
    required this.text,
    required this.color,
    required this.container,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color container;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: container,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.surface, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── page 1: quick add ─────────────────────────

class _QuickAddArt extends StatelessWidget {
  const _QuickAddArt();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              width: double.infinity,
              decoration: BoxDecoration(
                color: pal.expenseContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text('New expense',
                      style: tt.labelLarge?.copyWith(color: pal.expense)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('1,250',
                          style: tt.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800, color: pal.expense)),
                      const SizedBox(width: 4),
                      Container(width: 3, height: 40, color: pal.expense),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _Pill('Food', Icons.restaurant_rounded, selected: true),
                _Pill('Transport', Icons.directions_bus_rounded),
                _Pill('Bills', Icons.receipt_rounded),
                _Pill('Fun', Icons.sports_esports_rounded),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: pal.expense,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('Save expense',
                  style: tt.labelLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        Positioned(
          top: -40,
          right: -10,
          child: _FloatBadge(
            icon: Icons.check_circle_rounded,
            text: 'Saved in 5 sec',
            color: pal.income,
            container: pal.incomeContainer,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.icon, {this.selected = false});
  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 15,
              color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── page 2: insights ─────────────────────────

class _InsightsArt extends StatelessWidget {
  const _InsightsArt();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;

    final parts = <(String, double, Color)>[
      ('Food', 0.48, cs.primary),
      ('Bills', 0.27, cs.secondary),
      ('Travel', 0.16, cs.tertiary),
      ('Fun', 0.09, pal.warning),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _MiniDonutPainter(
                  parts: [for (final p in parts) (p.$2, p.$3)],
                  track: cs.surfaceContainerHighest,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Spent',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                      Text('14.2K',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  for (final p in parts)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: p.$3, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(p.$1, style: tt.bodyMedium)),
                          Text('${(p.$2 * 100).round()}%',
                              style: tt.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: -44,
          right: -10,
          child: _FloatBadge(
            icon: Icons.trending_down_rounded,
            text: '12% less than last month',
            color: pal.income,
            container: pal.incomeContainer,
          ),
        ),
      ],
    );
  }
}

class _MiniDonutPainter extends CustomPainter {
  _MiniDonutPainter({required this.parts, required this.track});
  final List<(double, Color)> parts;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track.withValues(alpha: 0.5),
    );

    var start = -math.pi / 2;
    for (final p in parts) {
      final sweep = p.$1 * 2 * math.pi;
      canvas.drawArc(
        rect,
        start + 0.03,
        sweep - 0.06,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = p.$2,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _MiniDonutPainter old) => false;
}

// ───────────────────────── page 3: budget ─────────────────────────

class _BudgetArt extends StatelessWidget {
  const _BudgetArt();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Monthly budget',
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pal.warning.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('82% used',
                      style: tt.labelMedium?.copyWith(
                          color: pal.warning, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.82,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              color: pal.warning,
              backgroundColor: cs.surfaceContainerHighest,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('Spent 8,200',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                const Spacer(),
                Text('1,800 left',
                    style: tt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800, color: pal.warning)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can spend about 120 a day for the rest of the month',
                      style:
                          tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: -44,
          right: -10,
          child: _FloatBadge(
            icon: Icons.flag_rounded,
            text: 'On track',
            color: cs.primary,
            container: cs.primaryContainer,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── page 4: privacy ─────────────────────────

class _PrivacyArt extends StatelessWidget {
  const _PrivacyArt();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    const points = [
      'Works fully offline',
      'No account or sign-up',
      'Your data stays on this device',
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.08),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.14),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: pal.heroGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child:
                      Icon(Icons.shield_rounded, size: 30, color: pal.onHero),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final p in points)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 20, color: pal.income),
                    const SizedBox(width: 10),
                    Expanded(child: Text(p, style: tt.bodyLarge)),
                  ],
                ),
              ),
          ],
        ),
        Positioned(
          top: -44,
          right: -10,
          child: _FloatBadge(
            icon: Icons.wifi_off_rounded,
            text: '100% offline',
            color: cs.primary,
            container: cs.primaryContainer,
          ),
        ),
      ],
    );
  }
}
