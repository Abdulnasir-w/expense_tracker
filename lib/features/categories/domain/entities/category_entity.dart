import 'package:equatable/equatable.dart';

enum CategoryType { income, expense, both }

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final CategoryType type;
  final bool isArchived;
  final int sortOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.type,
    this.isArchived = false,
    this.sortOrder = 0,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? iconKey,
    int? colorValue,
    CategoryType? type,
    bool? isArchived,
    int? sortOrder,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, name, iconKey, colorValue, type, isArchived, sortOrder];
}

