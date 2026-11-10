import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/account_entity.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';

class AccountsController extends AsyncNotifier<List<AccountEntity>> {
  @override
  Future<List<AccountEntity>> build() async {
    return ref.read(accountRepositoryProvider).getAccounts();
  }

  Future<void> addAccount(AccountEntity account) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).addAccount(account);
      return ref.read(accountRepositoryProvider).getAccounts();
    });
  }

  Future<void> updateAccount(AccountEntity account) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).updateAccount(account);
      return ref.read(accountRepositoryProvider).getAccounts();
    });
  }

  Future<void> archiveAccount(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).archiveAccount(id);
      return ref.read(accountRepositoryProvider).getAccounts();
    });
  }
}

final accountsProvider =
    AsyncNotifierProvider<AccountsController, List<AccountEntity>>(
  AccountsController.new,
);

final activeAccountsProvider = Provider<List<AccountEntity>>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
  return accounts.where((a) => !a.isArchived).toList();
});

/// Computes account balances dynamically from transaction list!
/// accountBalance = initialBalance
///                + sum(income to this account)
///                - sum(expenses from this account)
///                + sum(transfers into this account)
///                - sum(transfers out of this account)
final accountBalancesProvider = Provider<Map<String, int>>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
  final transactions = ref.watch(transactionControllerProvider).valueOrNull ?? [];

  final Map<String, int> balances = {};
  for (final a in accounts) {
    balances[a.id] = a.initialBalanceMinor;
  }

  for (final t in transactions) {
    if (t.isIncome) {
      balances[t.accountId] = (balances[t.accountId] ?? 0) + t.amountMinor;
    } else if (t.isExpense) {
      balances[t.accountId] = (balances[t.accountId] ?? 0) - t.amountMinor;
    } else if (t.isTransfer) {
      balances[t.accountId] = (balances[t.accountId] ?? 0) - t.amountMinor;
      if (t.toAccountId != null) {
        balances[t.toAccountId!] = (balances[t.toAccountId!] ?? 0) + t.amountMinor;
      }
    }
  }

  return balances;
});

