import 'dart:ui' show PlatformDispatcher;

import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:expense_tracker/features/profile/presentation/widgets/profile_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/constants/currency_options.dart';
import 'package:expense_tracker/core/storage/app_prefs.dart';
import 'package:expense_tracker/features/profile/domain/user_profile.dart';
import 'package:expense_tracker/features/profile/presentation/controllers/profile_controller.dart';

/// Last onboarding step: name, currency and an optional monthly budget.
/// Everything else can be completed later from the Profile screen.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _budget = TextEditingController();
  late String _currency =
      currencyForCountry(PlatformDispatcher.instance.locale.countryCode);
  String? _avatar;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  void _onAvatar(String? path) {
    final previous = _avatar;
    if (previous != null && previous != path) {
      ref.read(profileDataSourceProvider).deleteAvatar(previous);
    }
    setState(() => _avatar = path);
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(profileControllerProvider.notifier).save(
          UserProfile(
            name: _name.text.trim(),
            avatarPath: _avatar,
            currencyCode: _currency,
            monthlyBudgetMinor: parseMinor(_budget.text),
          ),
        );
    await ref.read(appPrefsProvider).setOnboardingDone();
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _skip() async {
    final previous = _avatar;
    if (previous != null) {
      await ref.read(profileDataSourceProvider).deleteAvatar(previous);
    }
    await ref.read(appPrefsProvider).setOnboardingDone();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pal = context.palette;
    final top = MediaQuery.paddingOf(context).top;
    final gradientHeight = top + 190;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    // Gradient header with the avatar straddling its edge
                    SizedBox(
                      height: gradientHeight + 64,
                      child: Stack(
                        children: [
                          Container(
                            height: gradientHeight,
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(24, top + 20, 24, 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: pal.heroGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(36)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: pal.onHero.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Last step',
                                    style: tt.labelMedium?.copyWith(
                                      color: pal.onHero,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Let\u2019s set up your profile',
                                  style: tt.headlineSmall?.copyWith(
                                    color: pal.onHero,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Two quick details so amounts show in your currency. You can change everything later.',
                                  style: tt.bodyMedium?.copyWith(
                                    color: pal.onHero.withValues(alpha: 0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: gradientHeight - 52,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: AvatarPicker(
                                name: _name.text,
                                path: _avatar,
                                onChanged: _onAvatar,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Add a photo (optional)',
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _name,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Your name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (v) => (v == null ||
                                      v.trim().length < 2)
                                  ? 'Enter your name (at least 2 characters)'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            CurrencyField(
                              code: _currency,
                              onChanged: (c) => setState(() => _currency = c),
                            ),
                            const SizedBox(height: 16),
                            MoneyField(
                              controller: _budget,
                              label: 'Monthly budget (optional)',
                              currencyCode: _currency,
                              helper: 'How much you plan to spend each month',
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned actions
            Container(
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, 8 + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outlineVariant)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _saving ? null : _continue,
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text('Continue'),
                    ),
                  ),
                  TextButton(
                    onPressed: _saving ? null : _skip,
                    child: const Text('Skip for now'),
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
