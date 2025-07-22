import 'package:hive/hive.dart';
import '../models/receipt.dart';

class StorageService {
  static Future<void> initHive() async {
    Hive.registerAdapter(ReceiptAdapter());
    Hive.registerAdapter(ReceiptItemAdapter());
  }

  Future<void> saveReceipt(Receipt receipt) async {
    final box = await Hive.openBox('receipts');
    await box.put(receipt.id, receipt);
  }

  Future<List<Receipt>> loadReceipts() async {
    final box = await Hive.openBox('receipts');
    return box.values.cast<Receipt>().toList();
  }
}
