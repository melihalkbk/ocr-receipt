@JS()
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('Tesseract.recognize')
external dynamic tesseractRecognize(
  dynamic image,
  String lang,
  dynamic options,
);

class OCRService {
  Future<String> recognizeText(dynamic imageBytes) async {
    final result = await promiseToFuture(
      tesseractRecognize(imageBytes, 'tur', null),
    );
    final data = getProperty(result, 'data');
    final text = getProperty(data, 'text');
    return text as String;
  }
}
