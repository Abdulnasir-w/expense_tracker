import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/features/profile/presentation/widgets/profile_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/storage/app_prefs.dart';
import 'package:expense_tracker/features/profile/domain/user_profile.dart';
import 'package:expense_tracker/features/profile/presentation/controllers/profile_controller.dart';
import 'package:expense_tracker/shared/widgets/app_tour.dart';
import 'package:expense_tracker/shared/widgets/category_badge.dart';
import 'package:expense_tracker/shared/widgets/screen_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider) ?? const UserProfile();
    final cs = Theme.of(context).colorScheme;
    final pal = context.palette;

    return AppStatusBar(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            ScreenHeader(
              title: 'Profile',
              leading: HeaderAction(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onTap: () => Navigator.maybePop(context),
              ),
              actions: [
                HeaderAction(
                  icon: Icons.edit_rounded,
                  tooltip: 'Edit profile',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
              ],
            ),
            _HeroCard(profile: profile),

            if (profile.completion < 1) _MissingCard(profile: profile),

            // Quick stats
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.payments_rounded,
                      color: cs.primary,
                      label: 'Currency',
                      value: profile.currencyCode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.south_west_rounded,
                      color: pal.income,
                      label: 'Income',
                      value: profile.monthlyIncomeMinor > 0
                          ? formatMoney(profile.monthlyIncomeMinor, '')
                              .trim()
                          : 'Not set',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.north_east_rounded,
                      color: pal.expense,
                      label: 'Budget',
                      value: profile.monthlyBudgetMinor > 0
                          ? formatMoney(profile.monthlyBudgetMinor, '')
                              .trim()
                          : 'Not set',
                    ),
                  ),
                ],
              ),
            ),

            if (profile.monthlyIncomeMinor > 0 && profile.monthlyBudgetMinor > 0)
              _PlanCard(profile: profile),

            const _SectionTitle('Contact'),
            _GroupCard(
              children: [
                _InfoRow(Icons.mail_outline_rounded, 'Email',
                    profile.email.isEmpty ? null : profile.email),
                _InfoRow(Icons.phone_outlined, 'Phone',
                    profile.phone.isEmpty ? null : profile.phone),
              ],
            ),

            const _SectionTitle('App'),
            _GroupCard(
              children: [
                InkWell(
                  onTap: () async {
                    await ref.read(appPrefsProvider).resetTour();
                    ref.read(tourRequestProvider.notifier).request();
                    if (context.mounted) context.go(AppRoutes.home);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CategoryBadge(
                            icon: Icons.explore_rounded,
                            color: cs.secondary,
                            size: 40),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Replay app tour',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                'A quick walkthrough of the main screens',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── hero ─────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final tt = Theme.of(context).textTheme;
    final pct = (profile.completion * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pal.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: pal.heroGradient.last.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration:
                    BoxDecoration(color: pal.onHero, shape: BoxShape.circle),
                child: ProfileAvatar(
                    name: profile.name, path: profile.avatarPath, radius: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleLarge?.copyWith(
                        color: pal.onHero,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email.isEmpty ? 'Add your email' : profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium?.copyWith(
                        color: pal.onHero.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Profile strength',
                style: tt.labelMedium
                    ?.copyWith(color: pal.onHero.withValues(alpha: 0.8)),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: tt.labelLarge?.copyWith(
                  color: pal.onHero,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: profile.completion,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            color: pal.onHero,
            backgroundColor: pal.onHero.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

class _MissingCard extends StatelessWidget {
  const _MissingCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dark = cs.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Complete your profile',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'A few details unlock a more personal experience.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in profile.missingFields)
                ActionChip(
                  avatar: Icon(Icons.add_rounded, size: 16, color: cs.primary),
                  label: Text(f),
                  onPressed: () => context.push(AppRoutes.editProfile),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── tiles & cards ─────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dark = cs.brightness == Brightness.dark;
    final notSet = value == 'Not set';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryBadge(icon: icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(label,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: notSet ? cs.outline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final dark = cs.brightness == Brightness.dark;

    final income = profile.monthlyIncomeMinor;
    final budget = profile.monthlyBudgetMinor;
    final over = budget > income;
    final diff = (income - budget).abs();
    final budgetFlex = over ? 1000 : (budget / income * 1000).round().clamp(0, 1000);
    final saveFlex = 1000 - budgetFlex;
    final savePct = over ? 0 : (100 - (budget / income * 100).round());

    Widget legend(Color c, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(text,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly plan',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                if (budgetFlex > 0)
                  Expanded(
                    flex: budgetFlex,
                    child: Container(
                        height: 12, color: over ? cs.error : cs.primary),
                  ),
                if (saveFlex > 0)
                  Expanded(
                    flex: saveFlex,
                    child: Container(height: 12, color: pal.income),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              legend(over ? cs.error : cs.primary,
                  'Budget ${formatMoney(budget, profile.currencyCode)}'),
              if (!over)
                legend(pal.income,
                    'Savings ${formatMoney(diff, profile.currencyCode)} ($savePct%)'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            over
                ? 'Your budget is ${formatMoney(diff, profile.currencyCode)} above your income.'
                : 'You plan to keep ${formatMoney(diff, profile.currencyCode)} each month.',
            style: tt.bodyMedium?.copyWith(
              color: over ? cs.error : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      );
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, indent: 70, color: cs.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CategoryBadge(icon: icon, color: cs.primary, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not set',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: value == null ? cs.outline : null,
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