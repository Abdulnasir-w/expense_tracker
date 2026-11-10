import '../../../../core/error/exceptions.dart';
import '../../../../core/database/hive_service.dart';
import '../models/category_model.dart';
import '../../domain/entities/category_entity.dart';

class CategoryLocalDatasource {
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final box = HiveService.categoriesBox;
      final models = box.values.toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return models.map(_toEntity).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch categories: $e');
    }
  }

  Future<CategoryEntity> addCategory(CategoryEntity entity) async {
    try {
      final box = HiveService.categoriesBox;
      final model = _toModel(entity);
      await box.put(model.id, model);
      return _toEntity(model);
    } catch (e) {
      throw DatabaseException('Failed to add category: $e');
    }
  }

  Future<CategoryEntity> updateCategory(CategoryEntity entity) async {
    try {
      final box = HiveService.categoriesBox;
      final model = _toModel(entity);
      await box.put(model.id, model);
      return _toEntity(model);
    } catch (e) {
      throw DatabaseException('Failed to update category: $e');
    }
  }

  Future<void> archiveCategory(String id) async {
    try {
      final box = HiveService.categoriesBox;
      final model = box.get(id);
      if (model != null) {
        model.isArchived = true;
        await model.save();
      }
    } catch (e) {
      throw DatabaseException('Failed to archive category: $e');
    }
  }

  CategoryModel _toModel(CategoryEntity e) => CategoryModel()
    ..id = e.id
    ..name = e.name
    ..iconKey = e.iconKey
    ..colorValue = e.colorValue
    ..type = e.type.name
    ..isArchived = e.isArchived
    ..sortOrder = e.sortOrder;

  CategoryEntity _toEntity(CategoryModel m) => CategoryEntity(
        id: m.id,
        name: m.name,
        iconKey: m.iconKey,
        colorValue: m.colorValue,
        type: switch (m.type) {
          'income' => CategoryType.income,
          'both' => CategoryType.both,
          _ => CategoryType.expense,
        },
        isArchived: m.isArchived,
        sortOrder: m.sortOrder,
      );
}

