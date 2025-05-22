import "dart:io";
import "package:path_provider/path_provider.dart";
import "package:http/http.dart" as http;

class ImageCacheService {
  static const String _cacheDirName = "image_cache";
  static const Duration _defaultExpiration = Duration(days: 7);

  Future<String> getCachedImagePath(String url) async {
    final cacheDir = await _getCacheDirectory();
    final fileName = _getFileNameFromUrl(url);
    return "${cacheDir.path}/$fileName";
  }

  Future<File?> getCachedImage(String url) async {
    final filePath = await getCachedImagePath(url);
    final file = File(filePath);
    if (await file.exists()) {
      final stat = await file.stat();
      if (DateTime.now().difference(stat.modified) < _defaultExpiration) {
        return file;
      }
    }
    return null;
  }

  Future<File> cacheImage(String url) async {
    final filePath = await getCachedImagePath(url);
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    }

    return file;
  }

  Future<void> clearCache() async {
    final cacheDir = await _getCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory("${appDir.path}/$_cacheDirName");
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final fileName = uri.pathSegments.last;
    return fileName.isEmpty ? "image_${DateTime.now().millisecondsSinceEpoch}" : fileName;
  }
}
