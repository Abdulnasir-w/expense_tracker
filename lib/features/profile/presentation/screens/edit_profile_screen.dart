import 'dart:ui' show PlatformDispatcher;

import 'package:expense_tracker/features/profile/presentation/widgets/profile_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/constants/currency_options.dart';
import 'package:expense_tracker/features/profile/domain/user_profile.dart';
import 'package:expense_tracker/features/profile/presentation/controllers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final UserProfile _original;
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _income;
  late final TextEditingController _budget;
  late String _currency;
  String? _avatar;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _original = ref.read(profileControllerProvider) ??
        UserProfile(
          currencyCode: currencyForCountry(
              PlatformDispatcher.instance.locale.countryCode),
        );
    _name = TextEditingController(text: _original.name);
    _email = TextEditingController(text: _original.email);
    _phone = TextEditingController(text: _original.phone);
    _income = TextEditingController(
        text: formatMinorInput(_original.monthlyIncomeMinor));
    _budget = TextEditingController(
        text: formatMinorInput(_original.monthlyBudgetMinor));
    _currency = _original.currencyCode;
    _avatar = _original.avatarPath;
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _income, _budget]) {
      c.dispose();
    }
    super.dispose();
  }

  /// A photo picked in this session but never saved is an orphan file.
  Future<void> _deleteIfUnsaved(String? path) async {
    if (path != null && path != _original.avatarPath) {
      await ref.read(profileDataSourceProvider).deleteAvatar(path);
    }
  }

  void _onAvatar(String? path) {
    _deleteIfUnsaved(_avatar);
    setState(() {
      _avatar = path;
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = _original.copyWith(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      avatarPath: _avatar,
      clearAvatar: _avatar == null,
      currencyCode: _currency,
      monthlyIncomeMinor: parseMinor(_income.text),
      monthlyBudgetMinor: parseMinor(_budget.text),
    );
    await ref.read(profileControllerProvider.notifier).save(updated);
    if (!mounted) return;
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
    context.pop();
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true) {
      await _deleteIfUnsaved(_avatar);
      if (mounted) {
        setState(() => _dirty = false);
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit profile'),
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: Text('Save',
                  style: TextStyle(
                      color: Theme.of(context).appBarTheme.foregroundColor)),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          onChanged: () {
            if (!_dirty) setState(() => _dirty = true);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Center(
                child: AvatarPicker(
                  name: _name.text,
                  path: _avatar,
                  onChanged: _onAvatar,
                ),
              ),
              const SizedBox(height: 28),
              Text('About you', style: tt.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Enter your name (at least 2 characters)'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return null;
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
                      ? null
                      : 'Enter a valid email address';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return null;
                  final digits = value.replaceAll(RegExp(r'[\s\-()+]'), '');
                  return RegExp(r'^\d{7,15}$').hasMatch(digits)
                      ? null
                      : 'Enter a valid phone number';
                },
              ),
              const SizedBox(height: 28),
              Text('Money', style: tt.titleMedium),
              const SizedBox(height: 12),
              CurrencyField(
                code: _currency,
                onChanged: (c) => setState(() {
                  _currency = c;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: 16),
              MoneyField(
                controller: _income,
                label: 'Monthly income',
                currencyCode: _currency,
              ),
              const SizedBox(height: 16),
              MoneyField(
                controller: _budget,
                label: 'Monthly budget',
                currencyCode: _currency,
                helper: 'How much you plan to spend each month',
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
