import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/core/constants/currency_options.dart';
import 'package:expense_tracker/features/profile/presentation/controllers/profile_controller.dart';

// ───────────────────────── money helpers ─────────────────────────

/// "1250.5" -> 125050 (minor units). Empty or invalid -> 0.
int parseMinor(String input) {
  final value = double.tryParse(input.trim());
  if (value == null || value < 0) return 0;
  return (value * 100).round();
}

/// 125050 -> "1250.5", 125000 -> "1250" (for pre-filling text fields).
String formatMinorInput(int minor) {
  if (minor <= 0) return '';
  final value = minor / 100;
  return minor % 100 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}

/// 125050 + "PKR" -> "PKR 1,250.5"
String formatMoney(int minor, String code) =>
    '$code ${NumberFormat('#,##0.##').format(minor / 100)}';

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
  if (parts.isEmpty) return '';
  return parts.take(2).map((e) => e[0].toUpperCase()).join();
}

// ───────────────────────── avatar ─────────────────────────

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.path,
    this.radius = 48,
  });

  final String name;
  final String? path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final file =
        (path != null && File(path!).existsSync()) ? File(path!) : null;
    final initials = initialsOf(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: cs.primaryContainer,
      foregroundImage: file != null ? FileImage(file) : null,
      child: initials.isEmpty
          ? Icon(Icons.person_rounded,
              size: radius, color: cs.onPrimaryContainer)
          : Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
                color: cs.onPrimaryContainer,
              ),
            ),
    );
  }
}

enum _AvatarAction { camera, gallery, remove }

/// Avatar with a camera badge. Opens a sheet to take, choose, or remove a photo.
/// Calls [onChanged] with the new saved path, or null when removed.
class AvatarPicker extends ConsumerWidget {
  const AvatarPicker({
    super.key,
    required this.name,
    required this.path,
    required this.onChanged,
    this.radius = 52,
  });

  final String name;
  final String? path;
  final ValueChanged<String?> onChanged;
  final double radius;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile photo',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SheetAction(
                      icon: Icons.photo_camera_rounded,
                      label: 'Camera',
                      onTap: () => Navigator.pop(ctx, _AvatarAction.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetAction(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => Navigator.pop(ctx, _AvatarAction.gallery),
                    ),
                  ),
                  if (path != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SheetAction(
                        icon: Icons.delete_outline_rounded,
                        label: 'Remove',
                        destructive: true,
                        onTap: () => Navigator.pop(ctx, _AvatarAction.remove),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (action == null) return;
    if (action == _AvatarAction.remove) {
      onChanged(null);
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: action == _AvatarAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 720,
      imageQuality: 85,
    );
    if (picked == null) return;
    final saved =
        await ref.read(profileDataSourceProvider).saveAvatar(picked.path);
    onChanged(saved);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Change profile photo',
      child: GestureDetector(
        onTap: () => _open(context, ref),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ProfileAvatar(name: name, path: path, radius: radius),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 3),
                ),
                child: Icon(Icons.photo_camera_rounded,
                    size: 15, color: cs.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = destructive ? cs.errorContainer : cs.primaryContainer;
    final fg = destructive ? cs.onErrorContainer : cs.onPrimaryContainer;
    return Material(
      color: bg.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: fg, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── layout helper ─────────────────────────

/// Rounded card with a title, used to group form fields.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
  });

  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dark = cs.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: cs.primary),
                const SizedBox(width: 8),
              ],
              Text(title,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            children[i],
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── fields ─────────────────────────

class CurrencyField extends StatelessWidget {
  const CurrencyField({super.key, required this.code, required this.onChanged});

  final String code;
  final ValueChanged<String> onChanged;

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CurrencySheet(selected: code),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final option = currencyByCode(code);
    return TextFormField(
      key: ValueKey(code),
      initialValue: '${option.name} (${option.code})',
      readOnly: true,
      onTap: () => _open(context),
      decoration: const InputDecoration(
        labelText: 'Currency',
        prefixIcon: Icon(Icons.payments_outlined),
        suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
      ),
    );
  }
}

class _CurrencySheet extends StatefulWidget {
  const _CurrencySheet({required this.selected});
  final String selected;

  @override
  State<_CurrencySheet> createState() => _CurrencySheetState();
}

class _CurrencySheetState extends State<_CurrencySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final q = _query.trim().toLowerCase();
    final items = kCurrencies
        .where((c) =>
            q.isEmpty ||
            c.name.toLowerCase().contains(q) ||
            c.code.toLowerCase().contains(q))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose currency',
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search currency',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text('No currency found',
                          style: tt.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final c = items[i];
                        final sel = c.code == widget.selected;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          selected: sel,
                          selectedTileColor:
                              cs.primaryContainer.withValues(alpha: 0.5),
                          leading: Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: sel ? cs.primary : cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              c.code,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: sel ? cs.onPrimary : cs.onSurface,
                              ),
                            ),
                          ),
                          title: Text(c.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: sel
                              ? Icon(Icons.check_circle_rounded,
                                  color: cs.primary)
                              : null,
                          onTap: () => Navigator.pop(context, c.code),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.label,
    required this.currencyCode,
    this.helper,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final String currencyCode;
  final String? helper;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,10}\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
        prefixText: '$currencyCode  ',
      ),
    );
  }
}
