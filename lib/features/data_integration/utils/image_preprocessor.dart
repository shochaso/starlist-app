import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Document AI が受け付けやすい JPEG 形式へ前処理するヘルパー。
Future<Uint8List> prepareImageForDocAi(Uint8List bytes) async {
  try {
    debugPrint('[DocAI] original bytes length: ${bytes.length}');
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      debugPrint('DocAI preprocessor: decode failed, using original bytes.');
      return bytes;
    }

    img.Image processed = decoded;
    const maxDimension = 1600;
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      processed = img.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? maxDimension : null,
        height: decoded.height > decoded.width ? maxDimension : null,
      );
    }

    final jpgBytes = img.encodeJpg(processed, quality: 85);
    debugPrint(
      '[DocAI] normalized bytes length: ${jpgBytes.length} (w=${processed.width}, h=${processed.height})',
    );
    return Uint8List.fromList(jpgBytes);
  } catch (e, _) {
    debugPrint('DocAI preprocessor error: $e');
    return bytes;
  }
}
