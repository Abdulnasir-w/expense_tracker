import 'package:equatable/equatable.dart';

enum BudgetPeriod { monthly }

class BudgetEntity extends Equatable {
  final String id;
  final String? categoryId; // null = overall monthly budget
  final int limitMinor;
  final BudgetPeriod period;

  const BudgetEntity({
    required this.id,
    this.categoryId,
    required this.limitMinor,
    this.period = BudgetPeriod.monthly,
  });

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    int? limitMinor,
    BudgetPeriod? period,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitMinor: limitMinor ?? this.limitMinor,
      period: period ?? this.period,
    );
  }

  @override
  List<Object?> get props => [id, categoryId, limitMinor, period];
}

