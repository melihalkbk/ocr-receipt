import 'package:flutter/material.dart';
import '../models/receipt.dart';

class ReceiptDetailView extends StatefulWidget {
  final Receipt receipt;
  final void Function(Receipt updatedReceipt) onSave;

  const ReceiptDetailView({
    super.key,
    required this.receipt,
    required this.onSave,
  });

  @override
  State<ReceiptDetailView> createState() => _ReceiptDetailViewState();
}

class _ReceiptDetailViewState extends State<ReceiptDetailView> {
  late DateTime _date;
  late double _total;
  late List<ReceiptItem> _items;

  @override
  void initState() {
    super.initState();
    _date = widget.receipt.date;
    _total = widget.receipt.total;
    _items = widget.receipt.items
        .map(
          (e) =>
              ReceiptItem(name: e.name, price: e.price, category: e.category),
        )
        .toList();
  }

  void _updateItem(int index, String name, double price, String category) {
    setState(() {
      _items[index] = ReceiptItem(name: name, price: price, category: category);
      _updateTotalFromItems();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _updateTotalFromItems();
    });
  }

  void _addItem() {
    setState(() {
      _items.add(ReceiptItem(name: '', price: 0, category: 'Diğer'));
      _updateTotalFromItems();
    });
  }

  void _updateTotalFromItems() {
    _total = _items.fold(0.0, (sum, item) => sum + (item.price ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiş Detayı & Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: _date.toLocal().toString().split(' ')[0],
                      decoration: const InputDecoration(labelText: 'Tarih'),
                      onChanged: (val) {
                        try {
                          _date = DateTime.parse(val);
                        } catch (_) {}
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.attach_money, size: 18, color: Colors.green),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: TextEditingController(
                        text: _total.toStringAsFixed(2),
                      ),
                      decoration: const InputDecoration(labelText: 'Toplam'),
                      keyboardType: TextInputType.number,
                      enabled: false,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ürünler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: _addItem,
                  ),
                ],
              ),
              ..._items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: item.name,
                            decoration: const InputDecoration(
                              labelText: 'Ürün Adı',
                            ),
                            onChanged: (val) =>
                                _updateItem(i, val, item.price, item.category),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: item.price.toStringAsFixed(2),
                            decoration: const InputDecoration(
                              labelText: 'Fiyat',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _updateItem(
                              i,
                              item.name,
                              double.tryParse(val.replaceAll(',', '.')) ??
                                  item.price,
                              item.category,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: item.category,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                            ),
                            onChanged: (val) =>
                                _updateItem(i, item.name, item.price, val),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(i),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Geri Dön'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final updated = Receipt(
                        id: widget.receipt.id,
                        date: _date,
                        items: _items,
                        total: _total,
                        rawText: widget.receipt.rawText,
                      );
                      widget.onSave(updated);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
