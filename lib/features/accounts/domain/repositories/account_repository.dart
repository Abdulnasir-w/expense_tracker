import '../../domain/entities/account_entity.dart';

abstract class AccountRepository {
  Future<List<AccountEntity>> getAccounts();
  Future<AccountEntity> addAccount(AccountEntity account);
  Future<AccountEntity> updateAccount(AccountEntity account);
  Future<void> archiveAccount(String id);
}

