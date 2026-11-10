import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDatasource _datasource;
  const AccountRepositoryImpl(this._datasource);

  @override
  Future<List<AccountEntity>> getAccounts() async {
    try {
      return await _datasource.getAccounts();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<AccountEntity> addAccount(AccountEntity account) async {
    try {
      return await _datasource.addAccount(account);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<AccountEntity> updateAccount(AccountEntity account) async {
    try {
      return await _datasource.updateAccount(account);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<void> archiveAccount(String id) async {
    try {
      await _datasource.archiveAccount(id);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }
}

