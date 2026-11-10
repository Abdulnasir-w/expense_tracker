import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/category_entity.dart';

class CategoriesController extends AsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    return ref.read(categoryRepositoryProvider).getCategories();
  }

  Future<void> addCategory(CategoryEntity category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).addCategory(category);
      return ref.read(categoryRepositoryProvider).getCategories();
    });
  }

  Future<void> updateCategory(CategoryEntity category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).updateCategory(category);
      return ref.read(categoryRepositoryProvider).getCategories();
    });
  }

  Future<void> archiveCategory(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).archiveCategory(id);
      return ref.read(categoryRepositoryProvider).getCategories();
    });
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesController, List<CategoryEntity>>(
  CategoriesController.new,
);

final activeCategoriesProvider = Provider<List<CategoryEntity>>((ref) {
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  return categories.where((c) => !c.isArchived).toList();
});

