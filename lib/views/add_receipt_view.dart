import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ocr_service.dart';
import '../services/parsing_service.dart';
import '../models/receipt.dart';

class AddReceiptView extends StatefulWidget {
  const AddReceiptView({super.key});

  @override
  State<AddReceiptView> createState() => _AddReceiptViewState();
}

class _AddReceiptViewState extends State<AddReceiptView> {
  Uint8List? _imageBytes;
  String? _ocrText;
  Receipt? _parsedReceipt;
  bool _isLoading = false;
  String? _error;

  final OCRService _ocrService = OCRService();
  final ParsingService _parsingService = ParsingService();

  Future<void> pickImageAndRecognize() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _ocrText = null;
      _parsedReceipt = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final bytes = result.files.first.bytes;
      if (bytes == null) {
        setState(() {
          _isLoading = false;
          _error = 'Görsel okunamadı.';
        });
        return;
      }
      setState(() {
        _imageBytes = bytes;
      });
      final text = await _ocrService.recognizeText(bytes);
      setState(() {
        _ocrText = text;
      });
      final receipt = _parsingService.parseReceipt(text);
      setState(() {
        _parsedReceipt = receipt;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Hata: $e';
      });
    }
  }

  Widget _buildInitialUpload() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload, size: 100, color: Colors.blue[100]),
        const SizedBox(height: 24),
        const Text(
          'Fiş Fotoğrafı Yükle',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Market veya restoran fişinin net bir fotoğrafını yükleyin. Fotoğrafın düz ve okunaklı olmasına dikkat edin.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: _isLoading ? null : pickImageAndRecognize,
          icon: const Icon(Icons.upload_file),
          label: const Text('Görsel Yükle ve OCR'),
        ),
      ],
    );
  }

  Widget _buildParsedReceipt(Receipt receipt) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                Text(
                  'Tarih: ${receipt.date.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Icon(Icons.attach_money, size: 18, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Toplam: ${receipt.total.toStringAsFixed(2)} TL',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Ürünler:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ...receipt.items.isEmpty
                ? [
                    const Text(
                      'Ürün bulunamadı.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ]
                : receipt.items.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        item.category,
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      trailing: Text(
                        '${item.price.toStringAsFixed(2)} TL',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Fiş Ekle & OCR')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_imageBytes == null &&
                    _ocrText == null &&
                    _parsedReceipt == null &&
                    !_isLoading &&
                    _error == null)
                  _buildInitialUpload(),
                if (_isLoading) ...[
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
                if (_imageBytes != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_imageBytes!, height: 220),
                  ),
                ],
                if (_ocrText != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OCR Sonucu:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _ocrText!,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_parsedReceipt != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Fişten Ayrıştırılanlar:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  _buildParsedReceipt(_parsedReceipt!),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 18,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.save, size: 28),
                      label: const Text('Fişi Kaydet'),
                      onPressed: () {
                        Navigator.of(context).pop(_parsedReceipt);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
