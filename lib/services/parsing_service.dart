import '../models/receipt.dart';

const Map<String, String> productCategoryMap = {
  // Dairy
  'süt': 'Süt Ürünleri',
  'sut': 'Süt Ürünleri',
  'milk': 'Süt Ürünleri',
  'peynir': 'Süt Ürünleri',
  'cheese': 'Süt Ürünleri',
  'yoğurt': 'Süt Ürünleri',
  'yogurt': 'Süt Ürünleri',
  // Bakery
  'ekmek': 'Fırın',
  'bread': 'Fırın',
  'poğaça': 'Fırın',
  'pogaca': 'Fırın',
  'börek': 'Fırın',
  'borek': 'Fırın',
  // Oil
  'zeytinyağı': 'Yağ',
  'zeytinyagi': 'Yağ',
  'ayçiçek': 'Yağ',
  'aycicek': 'Yağ',
  'oil': 'Yağ',
  // Beverage
  'su': 'İçecek',
  'water': 'İçecek',
  'kola': 'İçecek',
  'cola': 'İçecek',
  'ayran': 'İçecek',
  'soda': 'İçecek',
  'çay': 'İçecek',
  'cay': 'İçecek',
  // Meat
  'et': 'Et',
  'tavuk': 'Et',
  'chicken': 'Et',
  'balık': 'Et',
  'balik': 'Et',
  'fish': 'Et',
  // Snacks
  'cips': 'Atıştırmalık',
  'biskuvi': 'Atıştırmalık',
  'bisküvi': 'Atıştırmalık',
  'kraker': 'Atıştırmalık',
  'çikolata': 'Atıştırmalık',
  'cikolata': 'Atıştırmalık',
  // Fruit/Vegetable
  'elma': 'Meyve/Sebze',
  'apple': 'Meyve/Sebze',
  'domates': 'Meyve/Sebze',
  'tomato': 'Meyve/Sebze',
  'patates': 'Meyve/Sebze',
  'potato': 'Meyve/Sebze',
  // Other
  'deterjan': 'Temizlik',
  'sabun': 'Temizlik',
  'shampoo': 'Temizlik',
  'şampuan': 'Temizlik',
  // Extend as needed
};

class ParsingService {
  Receipt parseReceipt(String rawText) {
    final List<ReceiptItem> items = smartParseProducts(rawText);

    final totalRegex = RegExp(
      r'(GENEL TOPLAM|TOPLAM|TUTAR|TOTAL)[^\d]*(\d+[.,]?\d*)',
      caseSensitive: false,
    );
    final totalMatch = totalRegex.firstMatch(rawText);
    final total = totalMatch != null
        ? double.tryParse(totalMatch.group(2)!.replaceAll(',', '.')) ?? 0
        : 0;

    final dateRegex = RegExp(r'(\d{2}[./-]\d{2}[./-]\d{4})');
    final dateStr = dateRegex.firstMatch(rawText)?.group(1) ?? '';
    final date = dateStr.isNotEmpty
        ? DateTime.tryParse(
                dateStr.split(RegExp(r'[./-]')).reversed.join('-'),
              ) ??
              DateTime.now()
        : DateTime.now();

    return Receipt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      items: items,
      total: total.toDouble(),
      rawText: rawText,
    );
  }
}

List<ReceiptItem> smartParseProducts(String rawText) {
  final lines = rawText.split('\n');
  final List<ReceiptItem> items = [];
  final productLineRegex = RegExp(
    r'^(.+?)(?:\s+|\s*\([^\)]*\)\s*)(\d+[.,]?\d{0,2})\s*(TL|₺)?$',
    caseSensitive: false,
  );
  for (int i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();
    if (trimmed.isEmpty) continue;
    if (RegExp(r'^\d{8,14} ').hasMatch(trimmed)) continue;
    final lower = trimmed.toLowerCase();
    if (lower.contains('cashier') ||
        lower.contains('kasiyer') ||
        lower.contains('register') ||
        lower.contains('kasa') ||
        lower.contains('received amount') ||
        lower.contains('alınan para') ||
        lower.contains('change') ||
        lower.contains('para üstü') ||
        lower.contains('total') ||
        lower.contains('toplam') ||
        lower.contains('receipt') ||
        lower.contains('fiş') ||
        lower.contains('date') ||
        lower.contains('tarih') ||
        lower.contains('time') ||
        lower.contains('saat') ||
        lower.contains('genel toplam'))
      continue;
    if (!RegExp(r'[a-zA-ZçğıöşüÇĞİÖŞÜ]').hasMatch(trimmed) ||
        !RegExp(r'\d').hasMatch(trimmed))
      continue;
    final match = productLineRegex.firstMatch(trimmed);
    if (match != null) {
      final name = match.group(1)!.trim();
      final price = double.tryParse(match.group(2)!.replaceAll(',', '.')) ?? 0;
      if (isValidProductName(name) && price > 0) {
        final category = guessCategory(name);
        if (!items.any((item) => item.name == name && item.price == price)) {
          items.add(ReceiptItem(name: name, price: price, category: category));
        }
      }
      continue;
    }
    final qtyMatch = RegExp(
      r'(.+?)\(\s*(\d+)\s*ADET\s*X\s*(\d+[.,]?\d{0,2})\s*\)\s*(\d+[.,]?\d{0,2})',
    ).firstMatch(trimmed);
    if (qtyMatch != null) {
      final name = qtyMatch.group(1)!.trim();
      final qty = double.tryParse(qtyMatch.group(3)!) ?? 1;
      final unitPrice =
          double.tryParse(qtyMatch.group(4)!.replaceAll(',', '.')) ?? 0;
      final price = qty * unitPrice;
      if (isValidProductName(name) && price > 0) {
        final category = guessCategory(name);
        if (!items.any((item) => item.name == name && item.price == price)) {
          items.add(ReceiptItem(name: name, price: price, category: category));
        }
      }
      continue;
    }
    final qtyMatch2 = RegExp(
      r'(.+?)\s+(\d+)\s*(ADET|X|x)\s*(\d+[.,]?\d{0,2})',
    ).firstMatch(trimmed);
    if (qtyMatch2 != null) {
      final name = qtyMatch2.group(1)!.trim();
      final qty = double.tryParse(qtyMatch2.group(2)!) ?? 1;
      final unitPrice =
          double.tryParse(qtyMatch2.group(4)!.replaceAll(',', '.')) ?? 0;
      final price = qty * unitPrice;
      if (isValidProductName(name) && price > 0) {
        final category = guessCategory(name);
        if (!items.any((item) => item.name == name && item.price == price)) {
          items.add(ReceiptItem(name: name, price: price, category: category));
        }
      }
      continue;
    }
    if (isValidProductName(trimmed) && i + 1 < lines.length) {
      final nextLine = lines[i + 1].trim();
      final priceMatch = RegExp(
        r'^(\d+[.,]?\d{0,2})\s*(TL|₺)?$',
      ).firstMatch(nextLine);
      if (priceMatch != null) {
        final price =
            double.tryParse(priceMatch.group(1)!.replaceAll(',', '.')) ?? 0;
        if (price > 0) {
          final category = guessCategory(trimmed);
          if (!items.any(
            (item) => item.name == trimmed && item.price == price,
          )) {
            items.add(
              ReceiptItem(name: trimmed, price: price, category: category),
            );
          }
          i++;
        }
      }
    }
  }
  return items;
}

bool isValidProductName(String name) {
  final lower = name.toLowerCase().replaceAll(RegExp(r'[^a-zçğıöşü0-9 ]'), '');
  final forbidden = [
    'cashier',
    'kasiyer',
    'register',
    'kasa',
    'received amount',
    'alınan para',
    'change',
    'para üstü',
    'total',
    'toplam',
    'receipt',
    'fiş',
    'date',
    'tarih',
    'time',
    'saat',
    'genel toplam',
  ];
  for (final word in forbidden) {
    if (lower.contains(word)) return false;
  }
  if (name.trim().length < 3) return false;
  if (RegExp(r'^\d{8,14} ').hasMatch(name)) return false;
  return true;
}

String guessCategory(String name) {
  final lower = name.toLowerCase();
  final normalized = lower
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll('ş', 's')
      .replaceAll('ı', 'i')
      .replaceAll('ğ', 'g');
  for (final entry in productCategoryMap.entries) {
    if (normalized.contains(entry.key)) return entry.value;
  }
  return 'Other';
}
