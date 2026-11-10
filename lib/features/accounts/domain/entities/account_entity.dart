import 'package:equatable/equatable.dart';

enum AccountType { cash, bank, wallet, card }

class AccountEntity extends Equatable {
  final String id;
  final String name;
  final AccountType type;
  final String currencyCode;
  final int initialBalanceMinor;
  final int colorValue;
  final String iconKey;
  final bool isArchived;

  const AccountEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyCode,
    this.initialBalanceMinor = 0,
    required this.colorValue,
    required this.iconKey,
    this.isArchived = false,
  });

  AccountEntity copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? currencyCode,
    int? initialBalanceMinor,
    int? colorValue,
    String? iconKey,
    bool? isArchived,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currencyCode: currencyCode ?? this.currencyCode,
      initialBalanceMinor: initialBalanceMinor ?? this.initialBalanceMinor,
      colorValue: colorValue ?? this.colorValue,
      iconKey: iconKey ?? this.iconKey,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        currencyCode,
        initialBalanceMinor,
        colorValue,
        iconKey,
        isArchived,
      ];
}

