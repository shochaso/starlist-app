import 'dart:convert';
import 'dart:html' as html;

class DownloadHelper {
  static Future<void> downloadJson(String filename, String json) async {
    final bytes = utf8.encode(json);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = filename
      ..style.display = 'none';
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
} 