import 'package:expense_tracker/shared/widgets/color_dots.dart';
import 'package:expense_tracker/shared/widgets/sheet_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_category_icons.dart';
import '../../../../shared/widgets/category_badge.dart';
import '../../../../shared/widgets/form_kit.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../domain/entities/category_entity.dart';
import '../controllers/categories_controller.dart';

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  int _tab = 0; // 0 = expenses, 1 = income

  CategoryType get _currentType =>
      _tab == 0 ? CategoryType.expense : CategoryType.income;

  void _openSheet({CategoryEntity? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CategoryFormSheet(
        defaultType: _currentType,
        existing: existing,
      ),
    );
  }

  Future<void> _confirmArchive(CategoryEntity cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Archive category?'),
        content: Text(
            '"${cat.name}" will be hidden from pickers. Past transactions keep it.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Archive')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(categoriesProvider.notifier).archiveCategory(cat.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return AppStatusBar(
      child: Scaffold(
        body: Column(
          children: [
            ScreenHeader(
              title: 'Categories',
              subtitle: 'Organize your income and spending',
              leading: HeaderAction(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onTap: () => Navigator.maybePop(context),
              ),
              actions: [
                HeaderAction(
                  icon: Icons.add_rounded,
                  tooltip: 'Add category',
                  active: true,
                  onTap: () => _openSheet(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: PillToggle(
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
                options: [
                  PillOption('Expenses', icon: Icons.north_east_rounded),
                  PillOption('Income', icon: Icons.south_west_rounded),
                ],
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (categories) {
                  final list = categories.where((c) {
                    if (c.isArchived) return false;
                    return _tab == 0
                        ? (c.type == CategoryType.expense ||
                            c.type == CategoryType.both)
                        : (c.type == CategoryType.income ||
                            c.type == CategoryType.both);
                  }).toList();

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 74,
                    ),
                    itemCount: list.length + 1,
                    itemBuilder: (context, i) {
                      if (i == list.length) {
                        return AddRowTile(
                          label: 'New category',
                          onTap: () => _openSheet(),
                        );
                      }
                      final cat = list[i];
                      return _CategoryCard(
                        cat: cat,
                        onEdit: () => _openSheet(existing: cat),
                        onArchive: () => _confirmArchive(cat),
                      );
                    },
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.cat,
    required this.onEdit,
    required this.onArchive,
  });

  final CategoryEntity cat;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dark = cs.brightness == Brightness.dark;
    final color = Color(cat.colorValue);

    return Material(
      color: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 2, 0),
          child: Row(
            children: [
              CategoryBadge(
                icon: AppCategoryIcons.getIcon(cat.iconKey),
                color: color,
                size: 42,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      _cap(cat.type.name),
                      style:
                          tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert_rounded,
                    size: 18, color: cs.onSurfaceVariant),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'archive') onArchive();
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'archive', child: Text('Archive')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category form sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryFormSheet extends ConsumerStatefulWidget {
  const _CategoryFormSheet({required this.defaultType, this.existing});
  final CategoryType defaultType;
  final CategoryEntity? existing;

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CategoryType _type;
  late String _iconKey;
  late Color _color;

  static const _palette = [
    Color(0xFFE53935),
    Color(0xFFD81B60),
    Color(0xFF8E24AA),
    Color(0xFF3949AB),
    Color(0xFF1E88E5),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFFFDD835),
    Color(0xFFFB8C00),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
  ];

  static const _types = [
    CategoryType.expense,
    CategoryType.income,
    CategoryType.both,
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _type = e?.type ?? widget.defaultType;
    _iconKey = e?.iconKey ?? 'category';
    _color = e != null ? Color(e.colorValue) : _palette[4];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final category = CategoryEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      iconKey: _iconKey,
      colorValue: _color.toARGB32(),
      type: _type,
      isArchived: widget.existing?.isArchived ?? false,
      sortOrder: widget.existing?.sortOrder ?? 0,
    );

    if (widget.existing != null) {
      await ref.read(categoriesProvider.notifier).updateCategory(category);
    } else {
      await ref.read(categoriesProvider.notifier).addCategory(category);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEdit = widget.existing != null;
    final iconKeys = AppCategoryIcons.icons.keys.toList();
    final previewName = _nameController.text.trim();

    return Form(
      key: _formKey,
      child: SheetForm(
        title: isEdit ? 'Edit category' : 'New category',
        submitLabel: isEdit ? 'Save changes' : 'Create category',
        onSubmit: _submit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CategoryBadge(
                    icon: AppCategoryIcons.getIcon(_iconKey),
                    color: _color,
                    size: 54,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          previewName.isEmpty ? 'Category name' : previewName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: previewName.isEmpty
                                ? cs.onSurfaceVariant
                                : null,
                          ),
                        ),
                        Text(_cap(_type.name),
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Groceries, Freelance',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter a category name'
                  : null,
            ),
            const SizedBox(height: 18),
            const FormLabel('Applies to'),
            PillToggle(
              selected: _types.indexOf(_type),
              onChanged: (i) => setState(() => _type = _types[i]),
              options: const [
                PillOption('Expense'),
                PillOption('Income'),
                PillOption('Both'),
              ],
            ),
            const SizedBox(height: 18),
            const FormLabel('Color'),
            ColorDots(
              colors: _palette,
              selected: _color,
              onSelect: (c) => setState(() => _color = c),
            ),
            const SizedBox(height: 18),
            const FormLabel('Icon'),
            SizedBox(
              height: 176,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: iconKeys.length,
                itemBuilder: (ctx, i) {
                  final key = iconKeys[i];
                  final selected = _iconKey == key;
                  return GestureDetector(
                    onTap: () => setState(() => _iconKey = key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: selected
                            ? _color.withValues(alpha: 0.2)
                            : cs.surfaceContainerHigh.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? _color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        AppCategoryIcons.getIcon(key),
                        color: selected ? _color : cs.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
