import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// タグ付けのみ保存ヘルパー
///
/// 未対応サービスや未知フォーマットのデータを、
/// タグ情報のみ抽出して検索可能にする。
class TagOnlySaver {
  final _supabase = Supabase.instance.client;

  /// タグのみモードで保存
  ///
  /// [authorId] 投稿者のユーザーID
  /// [sourceId] データソースの一意識別子（URL or ハッシュ）
  /// [category] カテゴリ（例: 'video', 'shopping'）
  /// [service] サービス名（例: 'netflix', 'rakuten'）
  /// [brandOrStore] ブランドまたは店舗名（オプション）
  /// [freeTextKeywords] 自由テキストから抽出したキーワード配列
  /// [occurredAt] 実際の発生日時（視聴日、購入日など）
  /// [rawMetadata] 生データまたは軽量要約（JSON）
  Future<String> save({
    required String authorId,
    required String sourceId,
    required String category,
    String? service,
    String? brandOrStore,
    required List<String> freeTextKeywords,
    DateTime? occurredAt,
    Map<String, dynamic>? rawMetadata,
    bool isPublished = false,
  }) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('contents')
        .insert({
          'author_id': authorId,
          'title': null, // タグのみモードはタイトルなし
          'description': null,
          'type': 'text', // 既存のenum値に合わせる
          'url': null,
          'metadata': jsonEncode({
            'source_id': sourceId,
            'raw': rawMetadata ?? {},
            'ingest_mode': 'tag_only',
            'imported_at': now.toIso8601String(),
          }),
          'ingest_mode': 'tag_only',
          'confidence': null, // タグのみは信頼度なし
          'tags': freeTextKeywords.take(64).toList(), // 最大64個
          'occurred_at': occurredAt?.toIso8601String() ?? now.toIso8601String(),
          'category': category,
          'service': service,
          'brand_or_store': brandOrStore,
          'is_published': isPublished,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  /// 自由テキストからタグ配列を生成
  ///
  /// [category] カテゴリ（必須）
  /// [service] サービス名（オプション）
  /// [brandOrStore] ブランド・店舗名（オプション）
  /// [freeText] 自由テキスト（タイトル、説明など）
  ///
  /// 戻り値: 重複を除いたタグ配列（最大64個）
  static List<String> buildTags({
    required String category,
    String? service,
    String? brandOrStore,
    String? freeText,
  }) {
    final tags = <String>{};

    // 1. カテゴリを必ず追加
    tags.add(category);

    // 2. サービス名を追加
    if (service != null && service.isNotEmpty) {
      tags.add(service);
    }

    // 3. ブランド・店舗名を追加
    if (brandOrStore != null && brandOrStore.isNotEmpty) {
      tags.add(brandOrStore);
    }

    // 4. 自由テキストから単語抽出（2文字以上、最大60個）
    if (freeText != null && freeText.isNotEmpty) {
      final words = freeText
          .split(RegExp(r'[\s　、。・,/|「」【】\(\)（）]+'))
          .map((w) => w.trim())
          .where((w) => w.length >= 2) // 2文字以上
          .where((w) => !_isStopWord(w)) // ストップワード除外
          .take(60);

      tags.addAll(words);
    }

    // 5. 最大64個に制限
    return tags.take(64).toList();
  }

  /// ストップワード判定（除外すべき一般的な単語）
  static bool _isStopWord(String word) {
    const stopWords = {
      'の',
      'に',
      'は',
      'を',
      'た',
      'が',
      'で',
      'て',
      'と',
      'し',
      'れ',
      'さ',
      'ある',
      'いる',
      'も',
      'する',
      'から',
      'な',
      'こと',
      'として',
      'い',
      'や',
      'れる',
      'など',
      'なっ',
      'ない',
      'この',
      'ため',
      'その',
      'あっ',
      'よう',
      'また',
      'もの',
      'という',
      'あり',
      'まで',
      'られ',
      'なる',
      'へ',
      'か',
      'だ',
      'これ',
      'によって',
      'により',
      'おり',
      'より',
      'による',
      'ず',
      'なり',
      'られる',
      'において',
      'ば',
      'なかっ',
      'なく',
      'しかし',
      'について',
      'せ',
      'だっ',
      'その後',
      'できる',
      'それ',
      'う',
      'ので',
      'なお',
      'のみ',
      'でき',
      'き',
      'つ',
      'における',
      'および',
      'いう',
      'さらに',
      'でも',
      'ら',
      'たり',
      'その他',
      'に関する',
      'たち',
      'ます',
      'ん',
      'なら',
      'に対して',
    };

    return stopWords.contains(word);
  }

  /// テキストからソースIDを生成（ハッシュ）
  static String generateSourceId(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// タグのみモードの未確定カード情報を生成
  ///
  /// 候補が0件の場合に表示する「タグのみ保存」カード用のデータ。
  ///
  /// [rawText] 元の入力テキスト
  /// [category] カテゴリ
  /// [service] サービス名
  ///
  /// 戻り値: 未確定カード用のMap
  static Map<String, dynamic> buildUnconfirmedCard({
    required String rawText,
    required String category,
    String? service,
  }) {
    final tags = buildTags(
      category: category,
      service: service,
      freeText: rawText,
    );

    return {
      'mode': 'tag_only',
      'category': category,
      'service': service,
      'tags': tags,
      'rawText': rawText.substring(0, min(200, rawText.length)),
      'confidence': null,
      'isSelected': false,
      'isPublic': false,
    };
  }
}
