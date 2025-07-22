import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../services/storage_service.dart';

class ReceiptProvider extends ChangeNotifier {
  final StorageService storageService;
  List<Receipt> _receipts = [];

  ReceiptProvider(this.storageService);

  List<Receipt> get receipts => _receipts;

  Future<void> loadReceipts() async {
    _receipts = await storageService.loadReceipts();
    notifyListeners();
  }

  Future<void> addReceipt(Receipt receipt) async {
    await storageService.saveReceipt(receipt);
    _receipts.add(receipt);
    notifyListeners();
  }

  Future<void> updateReceipt(Receipt updated) async {
    final index = _receipts.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _receipts[index] = updated;
      await storageService.saveReceipt(updated);
      notifyListeners();
    }
  }
}
