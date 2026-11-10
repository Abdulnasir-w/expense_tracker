import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/core/storage/app_prefs.dart';

// ───────────────────────── model & providers ─────────────────────────

class TourStep {
  const TourStep({
    required this.targetKey,
    required this.icon,
    required this.title,
    required this.body,
  });

  final GlobalKey targetKey;
  final IconData icon;
  final String title;
  final String body;
}

/// One GlobalKey per highlighted widget. Attach them where the widgets live
/// (see INTEGRATION.md).
class TourKeys {
  final balanceCard = GlobalKey(debugLabel: 'tour_balance_card');
  final addButton = GlobalKey(debugLabel: 'tour_add_button');
  final navTransactions = GlobalKey(debugLabel: 'tour_nav_transactions');
  final navStatistics = GlobalKey(debugLabel: 'tour_nav_statistics');
  final navSettings = GlobalKey(debugLabel: 'tour_nav_settings');
}

final tourKeysProvider = Provider<TourKeys>((ref) => TourKeys());

/// Call `ref.read(tourRequestProvider.notifier).request()` to replay the tour.
class TourRequestNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void request() => state++;
}

final tourRequestProvider =
    NotifierProvider<TourRequestNotifier, int>(TourRequestNotifier.new);

// ───────────────────────── host ─────────────────────────

/// Wrap your app shell with this. It starts the tour once for new users
/// and again whenever [tourRequestProvider] is triggered.
class TourHost extends ConsumerStatefulWidget {
  const TourHost({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<TourHost> createState() => _TourHostState();
}

class _TourHostState extends ConsumerState<TourHost> {
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(appPrefsProvider).tourDone) {
        _start(delay: const Duration(milliseconds: 700));
      }
    });
  }

  Future<void> _start(
      {Duration delay = const Duration(milliseconds: 500)}) async {
    if (_running) return;
    _running = true;
    await Future<void>.delayed(delay);
    if (!mounted) {
      _running = false;
      return;
    }

    final k = ref.read(tourKeysProvider);
    final steps = [
      TourStep(
        targetKey: k.balanceCard,
        icon: Icons.account_balance_wallet_rounded,
        title: 'Your balance at a glance',
        body: 'Net balance, total income and total expenses live in this card.',
      ),
      TourStep(
        targetKey: k.addButton,
        icon: Icons.add_rounded,
        title: 'Log in seconds',
        body: 'Tap + to add an income or an expense. It works offline, so it is instant.',
      ),
      TourStep(
        targetKey: k.navTransactions,
        icon: Icons.receipt_long_rounded,
        title: 'Your full history',
        body: 'Browse everything you have logged. Swipe a row to delete it.',
      ),
      TourStep(
        targetKey: k.navStatistics,
        icon: Icons.pie_chart_rounded,
        title: 'Understand your spending',
        body: 'Charts show where your money goes, category by category.',
      ),
      TourStep(
        targetKey: k.navSettings,
        icon: Icons.tune_rounded,
        title: 'Make it yours',
        body: 'Change the theme, edit your profile and replay this tour here.',
      ),
    ];

    await AppTour.show(context, steps);
    await ref.read(appPrefsProvider).setTourDone();
    _running = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(tourRequestProvider, (_, __) => _start());
    return widget.child;
  }
}

// ───────────────────────── overlay ─────────────────────────

Rect? _rectOf(GlobalKey key) {
  final ctx = key.currentContext;
  if (ctx == null) return null;
  final ro = ctx.findRenderObject();
  if (ro is! RenderBox || !ro.attached || !ro.hasSize) return null;
  return ro.localToGlobal(Offset.zero) & ro.size;
}

class AppTour {
  AppTour._();
  static OverlayEntry? _entry;

  /// Shows the tour and completes when the user finishes or skips.
  /// Steps whose target is not on screen are skipped automatically.
  static Future<void> show(BuildContext context, List<TourStep> steps) {
    if (_entry != null) return Future.value();
    final visible = steps.where((s) => _rectOf(s.targetKey) != null).toList();
    if (visible.isEmpty) return Future.value();

    final done = Completer<void>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TourOverlay(
        steps: visible,
        onClose: () {
          entry.remove();
          entry.dispose();
          _entry = null;
          if (!done.isCompleted) done.complete();
        },
      ),
    );
    _entry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
    return done.future;
  }
}

class _TourOverlay extends StatefulWidget {
  const _TourOverlay({required this.steps, required this.onClose});
  final List<TourStep> steps;
  final VoidCallback onClose;

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay> {
  int _i = 0;
  bool get _last => _i == widget.steps.length - 1;

  void _next() => _last ? widget.onClose() : setState(() => _i++);
  void _back() {
    if (_i > 0) setState(() => _i--);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final step = widget.steps[_i];
    final target = _rectOf(step.targetKey) ??
        Rect.fromCenter(center: size.center(Offset.zero), width: 0, height: 0);
    final cardAbove = target.center.dy > size.height * 0.5;

    final card = Material(
      key: ValueKey(_i),
      color: cs.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(step.icon, size: 20, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(step.title,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text('${_i + 1} of ${widget.steps.length}',
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),
            Text(step.body,
                style: tt.bodyMedium?.copyWith(height: 1.4, color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (!_last)
                  TextButton(onPressed: widget.onClose, child: const Text('Skip')),
                const Spacer(),
                if (_i > 0) TextButton(onPressed: _back, child: const Text('Back')),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: _next,
                  child: Text(_last ? 'Done' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // absorb taps behind the scrim
              child: TweenAnimationBuilder<Rect?>(
                tween: RectTween(end: target),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                builder: (_, rect, __) => CustomPaint(
                  painter: _SpotlightPainter(
                    hole: rect ?? target,
                    scrim: Colors.black.withValues(alpha: 0.78),
                    outline: cs.primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Align(
                key: ValueKey(_i),
                alignment: cardAbove ? Alignment.bottomCenter : Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: cardAbove ? 0 : target.bottom + 22,
                    bottom: cardAbove ? size.height - target.top + 22 : 0,
                  ),
                  child: card,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.hole,
    required this.scrim,
    required this.outline,
  });

  final Rect hole;
  final Color scrim;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final inflated = hole.inflate(8);
    final nearlySquare = (hole.width - hole.height).abs() < 8;
    final radius = Radius.circular(nearlySquare ? inflated.shortestSide / 2 : 16);
    final rrect = RRect.fromRectAndRadius(inflated, radius);

    final full = Path()..addRect(Offset.zero & size);
    final cut = Path()..addRRect(rrect);
    canvas.drawPath(Path.combine(PathOperation.difference, full, cut),
        Paint()..color = scrim);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = outline,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.scrim != scrim || old.outline != outline;
}