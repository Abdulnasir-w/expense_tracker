import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/theme/app_colors.dart';

/// First screen a new user sees. The hero is a paper receipt: the most
/// recognisable object in the world of spending.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final Animation<double> _receipt = CurvedAnimation(
    parent: _enter,
    curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _text = CurvedAnimation(
    parent: _enter,
    curve: const Interval(0.45, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: pal.heroGradient,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: FadeTransition(
                    opacity: _receipt,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.18),
                        end: Offset.zero,
                      ).animate(_receipt),
                      child: Transform.rotate(
                        angle: -0.05,
                        child: const _Receipt(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: FadeTransition(
              opacity: _text,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Know where your money goes',
                              style: tt.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Log income and expenses in seconds, set budgets, '
                              'and see clear reports. Everything stays on your phone.',
                              style: tt.bodyLarge?.copyWith(
                                color: cs.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: () => context.go(AppRoutes.onboarding),
                              child: const Text('Get started'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  size: 16, color: cs.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                'No account needed',
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── receipt illustration ─────────────────────────

const _paper = Color(0xFFFFFBF5);
const _ink = Color(0xFF2B2118);

class _Receipt extends StatelessWidget {
  const _Receipt();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Salary', '+45,000', true),
      ('Groceries', '-3,250', false),
      ('Fuel', '-1,800', false),
      ('Chai with friends', '-320', false),
    ];
    final tabular = const TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
      color: _ink,
      fontSize: 14,
    );

    return SizedBox(
      width: 250,
      child: PhysicalShape(
        clipper: _ZigZagClipper(),
        color: _paper,
        elevation: 10,
        shadowColor: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'THIS MONTH',
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              const _Dashed(),
              const SizedBox(height: 12),
              for (final r in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(r.$1, style: tabular)),
                      Text(
                        r.$2,
                        style: tabular.copyWith(
                          fontWeight: FontWeight.w600,
                          color: r.$3
                              ? AppColors.incomeGreen
                              : AppColors.expenseRed,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              const _Dashed(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Balance',
                        style: tabular.copyWith(
                            fontWeight: FontWeight.w800, fontSize: 17)),
                  ),
                  Text('39,630',
                      style: tabular.copyWith(
                          fontWeight: FontWeight.w800, fontSize: 17)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        final count = (box.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
                width: 4, height: 1.5, color: _ink.withValues(alpha: 0.4)),
          ),
        );
      },
    );
  }
}

class _ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const tooth = 9.0;
    final teeth = (size.width / 14).floor();
    final step = size.width / teeth;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height);
    for (var i = 0; i < teeth; i++) {
      final x = size.width - step * i;
      path
        ..lineTo(x - step / 2, size.height - tooth)
        ..lineTo(x - step, size.height);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
