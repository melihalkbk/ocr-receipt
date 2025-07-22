import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'ocr_service_base.dart';

class MobileOCRService implements BaseOCRService {
  @override
  Future<String> recognizeText(dynamic imagePath) async {
    return await TesseractOcr.extractText(imagePath);
  }
}
