import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/transactions/data/models/transaction_model.dart';

/// Singleton service that manages the Hive CE database lifecycle.
///
/// Call [HiveService.init()] once in [main()] before [runApp()].
class HiveService {
  HiveService._();

  static const String transactionsBoxName = 'transactions';

  /// Initialises Hive and registers all adapters.
  /// Must be called before accessing any box.
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    // Register generated adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionTypeHiveAdapter());
    }

    // Open boxes
    await Hive.openBox<TransactionModel>(transactionsBoxName);
  }

  /// Returns the transactions box — assumed to already be open.
  static Box<TransactionModel> get transactionsBox =>
      Hive.box<TransactionModel>(transactionsBoxName);

  /// Closes all open boxes — call on app teardown if needed.
  static Future<void> closeAll() async => Hive.close();
}
