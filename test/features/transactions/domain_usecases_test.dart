import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/domain/usecases/add_transaction.dart';
import 'package:expense_tracker/features/transactions/domain/usecases/get_transactions.dart';
import 'package:expense_tracker/features/transactions/domain/usecases/update_transaction.dart';
import 'package:expense_tracker/features/transactions/domain/usecases/delete_transaction.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late GetTransactions getTransactions;
  late AddTransaction addTransaction;
  late UpdateTransaction updateTransaction;
  late DeleteTransaction deleteTransaction;

  setUp(() {
    mockRepo = MockTransactionRepository();
    getTransactions = GetTransactions(mockRepo);
    addTransaction = AddTransaction(mockRepo);
    updateTransaction = UpdateTransaction(mockRepo);
    deleteTransaction = DeleteTransaction(mockRepo);
  });

  final testTransaction = TransactionEntity(
    id: 'uuid_test_1',
    type: TransactionType.income,
    amountMinor: 500000, // $5,000.00
    currencyCode: 'USD',
    categoryId: 'cat_salary',
    accountId: 'account_cash_default',
    date: DateTime(2026, 11, 1),
    title: 'Salary',
    createdAt: DateTime(2026, 11, 1),
    updatedAt: DateTime(2026, 11, 1),
  );

  group('Transactions UseCases', () {
    test('GetTransactions calls repository.getAllTransactions and returns items', () async {
      when(() => mockRepo.getAllTransactions())
          .thenAnswer((_) async => [testTransaction]);

      final result = await getTransactions.call();

      expect(result, equals([testTransaction]));
      verify(() => mockRepo.getAllTransactions()).called(1);
    });

    test('AddTransaction delegates to repository.addTransaction', () async {
      when(() => mockRepo.addTransaction(testTransaction))
          .thenAnswer((_) async => testTransaction);

      final result = await addTransaction.call(testTransaction);

      expect(result, equals(testTransaction));
      verify(() => mockRepo.addTransaction(testTransaction)).called(1);
    });

    test('UpdateTransaction delegates to repository.updateTransaction', () async {
      when(() => mockRepo.updateTransaction(testTransaction))
          .thenAnswer((_) async => testTransaction);

      final result = await updateTransaction.call(testTransaction);

      expect(result, equals(testTransaction));
      verify(() => mockRepo.updateTransaction(testTransaction)).called(1);
    });

    test('DeleteTransaction delegates to repository.deleteTransaction', () async {
      when(() => mockRepo.deleteTransaction('uuid_test_1')).thenAnswer((_) async {});

      await deleteTransaction.call('uuid_test_1');

      verify(() => mockRepo.deleteTransaction('uuid_test_1')).called(1);
    });
  });
}
