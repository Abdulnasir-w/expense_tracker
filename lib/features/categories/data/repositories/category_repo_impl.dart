import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource _datasource;
  const CategoryRepositoryImpl(this._datasource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      return await _datasource.getCategories();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<CategoryEntity> addCategory(CategoryEntity category) async {
    try {
      return await _datasource.addCategory(category);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    try {
      return await _datasource.updateCategory(category);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<void> archiveCategory(String id) async {
    try {
      await _datasource.archiveCategory(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }
}

