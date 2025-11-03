import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/services/image_url_builder.dart';

void main() {
  group('ImageUrlBuilder', () {
    test('builds thumbnail URL with defaults', () {
      const raw = 'public/derived/sample.jpg';
      final result = ImageUrlBuilder.thumbnail(raw);
      expect(
        result,
        equals(
          'https://cdn.starlist.jp/cdn-cgi/image/width=480,format=auto,quality=85,fit=cover/public/derived/sample.jpg',
        ),
      );
    });

    test('strips CDN origin before composing thumbnail', () {
      const raw = 'https://cdn.starlist.jp/public/derived/cover.png';
      final result = ImageUrlBuilder.thumbnail(raw, width: 720);
      expect(
        result,
        equals(
          'https://cdn.starlist.jp/cdn-cgi/image/width=720,format=auto,quality=85,fit=cover/public/derived/cover.png',
        ),
      );
    });

    test('original rewrites to CDN origin', () {
      const raw = 'https://supabase.example.com/storage/v1/object/public/icons/icon.png';
      final result = ImageUrlBuilder.original(raw);
      expect(
        result,
        equals(
          'https://cdn.starlist.jp/storage/v1/object/public/icons/icon.png',
        ),
      );
    });
  });
}
