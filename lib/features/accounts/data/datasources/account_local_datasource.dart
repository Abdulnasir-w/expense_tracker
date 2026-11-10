import '../../../../core/error/exceptions.dart';
import '../../../../core/database/hive_service.dart';
import '../models/account_model.dart';
import '../../domain/entities/account_entity.dart';

class AccountLocalDatasource {
  Future<List<AccountEntity>> getAccounts() async {
    try {
      final box = HiveService.accountsBox;
      return box.values.map(_toEntity).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch accounts: $e');
    }
  }

  Future<AccountEntity> addAccount(AccountEntity entity) async {
    try {
      final box = HiveService.accountsBox;
      final model = _toModel(entity);
      await box.put(model.id, model);
      return _toEntity(model);
    } catch (e) {
      throw DatabaseException('Failed to add account: $e');
    }
  }

  Future<AccountEntity> updateAccount(AccountEntity entity) async {
    try {
      final box = HiveService.accountsBox;
      final model = _toModel(entity);
      await box.put(model.id, model);
      return _toEntity(model);
    } catch (e) {
      throw DatabaseException('Failed to update account: $e');
    }
  }

  Future<void> archiveAccount(String id) async {
    try {
      final box = HiveService.accountsBox;
      final model = box.get(id);
      if (model != null) {
        model.isArchived = true;
        await model.save();
      }
    } catch (e) {
      throw DatabaseException('Failed to archive account: $e');
    }
  }

  AccountModel _toModel(AccountEntity e) => AccountModel()
    ..id = e.id
    ..name = e.name
    ..type = e.type.name
    ..currencyCode = e.currencyCode
    ..initialBalanceMinor = e.initialBalanceMinor
    ..colorValue = e.colorValue
    ..iconKey = e.iconKey
    ..isArchived = e.isArchived;

  AccountEntity _toEntity(AccountModel m) => AccountEntity(
        id: m.id,
        name: m.name,
        type: switch (m.type) {
          'bank' => AccountType.bank,
          'wallet' => AccountType.wallet,
          'card' => AccountType.card,
          _ => AccountType.cash,
        },
        currencyCode: m.currencyCode,
        initialBalanceMinor: m.initialBalanceMinor,
        colorValue: m.colorValue,
        iconKey: m.iconKey,
        isArchived: m.isArchived,
      );
}

