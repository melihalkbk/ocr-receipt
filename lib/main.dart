import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/add_receipt_view.dart';
import 'providers/receipt_provider.dart';
import 'services/storage_service.dart';
import 'models/receipt.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'views/receipt_detail_view.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.initHive();
  runApp(const ReceiptOCRApp());
}

class ReceiptOCRApp extends StatelessWidget {
  const ReceiptOCRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReceiptProvider(StorageService())..loadReceipts(),
        ),
      ],
      child: MaterialApp(
        title: 'Fiş OCR ve Harcama Takibi',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF7F8FA),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: StadiumBorder(),
          ),
        ),
        home: const HomeView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Map<String, double> getCategoryTotals(List<Receipt> receipts) {
    final Map<String, double> totals = {};
    for (final receipt in receipts) {
      for (final item in receipt.items) {
        totals[item.category] = (totals[item.category] ?? 0) + item.price;
      }
    }
    return totals;
  }

  String getTopCategory(Map<String, double> categoryTotals) {
    if (categoryTotals.isEmpty) return '-';
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return '${sorted.first.key} (${sorted.first.value.toStringAsFixed(2)} TL)';
  }

  ReceiptItem? getMostExpensiveItem(List<Receipt> receipts) {
    ReceiptItem? maxItem;
    for (final receipt in receipts) {
      for (final item in receipt.items) {
        if (maxItem == null || item.price > maxItem.price) {
          maxItem = item;
        }
      }
    }
    return maxItem;
  }

  Widget buildCategoryLegend(Map<String, double> data, List<Color> colors) {
    final entries = data.entries.toList();
    return Wrap(
      spacing: 16,
      children: List.generate(entries.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, color: colors[i % colors.length]),
            const SizedBox(width: 6),
            Text(entries[i].key, style: const TextStyle(fontSize: 14)),
          ],
        );
      }),
    );
  }

  Widget buildCategoryPieChart(Map<String, double> data) {
    if (data.isEmpty) {
      return const Center(child: Text('Kategori verisi yok.'));
    }
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final entries = data.entries.toList();
    final total = data.values.fold<double>(0, (sum, v) => sum + v);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (i) {
                final entry = entries[i];
                final percent = total > 0 ? (entry.value / total * 100) : 0;
                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: entry.value,
                  title: '${percent.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 32),
        buildCategoryLegend(data, colors),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReceiptProvider>(context);
    final receipts = provider.receipts;
    final total = receipts.fold<double>(0, (sum, r) => sum + r.total);
    final categoryTotals = getCategoryTotals(receipts);
    return Scaffold(
      appBar: AppBar(title: const Text('Fişlerim')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.summarize, size: 36, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Toplam Harcama',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${total.toStringAsFixed(2)} TL',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(
                          'Fiş Sayısı',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${receipts.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (receipts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16, right: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'En Çok Harcanan Kategori',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              getTopCategory(categoryTotals),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16, left: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'En Pahalı Ürün',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (_) {
                                final item = getMostExpensiveItem(receipts);
                                if (item == null) return const Text('-');
                                return Text(
                                  '${item.name} (${item.price.toStringAsFixed(2)} TL)',
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategoriye Göre Harcama Dağılımı',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      buildCategoryPieChart(categoryTotals),
                    ],
                  ),
                ),
              ),
            ],
            if (receipts.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 100,
                        color: Colors.blue[100],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Henüz hiç fiş eklemediniz.',
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sağ alttan yeni bir fiş ekleyebilirsiniz.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: receipts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final receipt = receipts[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.receipt, color: Colors.blue),
                        title: Text(
                          'Tarih: ${receipt.date.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Toplam: ${receipt.total.toStringAsFixed(2)} TL',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final updated = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReceiptDetailView(
                                receipt: receipt,
                                onSave: (updatedReceipt) {
                                  provider.updateReceipt(updatedReceipt);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fiş güncellendi!'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddReceiptView()));
          if (result is Receipt) {
            provider.addReceipt(result);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fiş başarıyla eklendi!')),
            );
          }
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Fiş Ekle'),
      ),
    );
  }
}
