import 'package:hive/hive.dart';
part 'receipt.g.dart';

@HiveType(typeId: 0)
class Receipt extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  DateTime date;
  @HiveField(2)
  List<ReceiptItem> items;
  @HiveField(3)
  double total;
  @HiveField(4)
  String rawText;

  Receipt({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.rawText,
  });
}

@HiveType(typeId: 1)
class ReceiptItem extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  double price;
  @HiveField(2)
  String category;

  ReceiptItem({
    required this.name,
    required this.price,
    required this.category,
  });
}
