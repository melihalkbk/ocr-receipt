import 'package:flutter/foundation.dart' show kIsWeb;
import 'ocr_service_base.dart';
import 'ocr_service_web.dart';
import 'ocr_service_mobile.dart';
import 'dart:io' show Platform;

BaseOCRService getOCRService() {
  if (kIsWeb) {
    return WebOCRService();
  } else if (Platform.isAndroid || Platform.isIOS) {
    return MobileOCRService();
  } else {
    throw UnsupportedError('Bu platformda OCR desteklenmiyor.');
  }
}
