import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/group.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/theme_option.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../../../shared/widgets/app_tour.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/widgets/profile_form_widget.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(profileControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final tx = Theme.of(context).textTheme;
    final pal = context.palette;

    return AppStatusBar(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.only(bottom: 150),
          children: [
            const ScreenHeader(
              title: 'Settings',
              subtitle: 'Make the app yours',
            ),

            // ── Profile card ─────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: pal.heroGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: pal.heroGradient.last.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => context.push(AppRoutes.profile),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: pal.onHero, shape: BoxShape.circle),
                          child: ProfileAvatar(
                            name: profile?.name ?? '',
                            path: profile?.avatarPath,
                            radius: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.displayName ?? 'My profile',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: pal.onHero,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile?.email.isNotEmpty == true
                                    ? profile!.email
                                    : 'Tap to view and edit your profile',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: pal.onHero.withValues(alpha: 0.8),
                                    ),
                              ),
                              if (profile != null &&
                                  profile.completion < 1.0) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: profile.completion,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                        color: pal.onHero,
                                        backgroundColor:
                                            pal.onHero.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${(profile.completion * 100).round()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: pal.onHero,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, color: pal.onHero),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Appearance ───────────────────────────────────────────
            Group(
              title: 'Appearance',
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: ThemeOption(
                          icon: Icons.auto_mode_rounded,
                          label: 'System',
                          selected: themeMode == ThemeMode.system,
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(ThemeMode.system),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ThemeOption(
                          icon: Icons.light_mode_rounded,
                          label: 'Light',
                          selected: themeMode == ThemeMode.light,
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ThemeOption(
                          icon: Icons.dark_mode_rounded,
                          label: 'Dark',
                          selected: themeMode == ThemeMode.dark,
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(ThemeMode.dark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Preferences ──────────────────────────────────────────
            Group(
              title: 'Preferences',
              children: [
                Tile(
                  icon: Icons.currency_exchange_rounded,
                  color: pal.income,
                  title: 'Currency',
                  subtitle: 'Default (USD - \$)',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Multi-currency coming in next release'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),

            // ── Manage & Plan ─────────────────────────────────────────
            Group(
              title: 'Manage & Plan',
              children: [
                Tile(
                  icon: Icons.account_balance_wallet_outlined,
                  color: cs.primary,
                  title: 'Accounts & Wallets',
                  subtitle: 'Manage cash, bank & card balances',
                  onTap: () => context.push(AppRoutes.accounts),
                ),
                Tile(
                  icon: Icons.category_outlined,
                  color: cs.secondary,
                  title: 'Categories',
                  subtitle: 'Customize income and expense categories',
                  onTap: () => context.push(AppRoutes.categories),
                ),
                Tile(
                  icon: Icons.pie_chart_outline_rounded,
                  color: cs.tertiary,
                  title: 'Monthly Budgets',
                  subtitle: 'Set category limits and track overspending',
                  onTap: () => context.push(AppRoutes.budgets),
                ),
                Tile(
                  icon: Icons.autorenew_rounded,
                  color: pal.income,
                  title: 'Recurring & Subscriptions',
                  subtitle: 'Automate bills, rent and regular salaries',
                  onTap: () => context.push(AppRoutes.recurring),
                ),
              ],
            ),

            // ── Account & help ───────────────────────────────────────
            Group(
              title: 'Account & help',
              children: [
                Tile(
                  icon: Icons.person_rounded,
                  color: cs.primary,
                  title: 'User profile',
                  subtitle: 'View and edit your details and budget',
                  onTap: () => context.push(AppRoutes.profile),
                ),
                Tile(
                  icon: Icons.explore_rounded,
                  color: cs.secondary,
                  title: 'Replay app tour',
                  subtitle: 'Quick walkthrough of key features',
                  onTap: () async {
                    await ref.read(appPrefsProvider).resetTour();
                    ref.read(tourRequestProvider.notifier).request();
                    if (context.mounted) context.go(AppRoutes.home);
                  },
                ),
                Tile(
                  icon: Icons.school_rounded,
                  color: pal.warning,
                  title: 'Replay welcome & onboarding',
                  subtitle: 'View the intro slides and profile setup',
                  onTap: () async {
                    await ref.read(appPrefsProvider).resetOnboarding();
                    if (context.mounted) context.go(AppRoutes.welcome);
                  },
                ),
              ],
            ),

            // ── About ────────────────────────────────────────────────
            Group(
              title: 'About',
              children: [
                Tile(
                  icon: Icons.info_rounded,
                  color: cs.tertiary,
                  title: 'Version',
                  trailing: Text(
                    '1.0.0+1',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                Tile(
                  icon: Icons.privacy_tip_rounded,
                  color: pal.income,
                  title: 'Privacy policy',
                  subtitle: '100% offline and local data',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Data privacy'),
                        content: const Text(
                          'Expense Tracker does not collect, share, or transmit your personal financial records to any remote server. All transactions remain securely on your local device storage.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  'Expense Tracker · made with care',
                  style: tx.bodySmall?.copyWith(color: cs.outline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
