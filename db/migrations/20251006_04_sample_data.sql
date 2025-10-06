-- =============================================
-- Starlist 検索機能用サンプルデータ挿入
-- テスト・デモ用途
-- =============================================

BEGIN;

-- 1. サンプルユーザーの作成（auth.usersテーブルは通常Supabase Authが管理するため、
--    実際の運用ではここは実行しない。テスト用のダミーUUIDを使用）

-- テスト用のダミーUUID
-- ユーザー1: テックレビューアー田中
-- ユーザー2: 料理研究家佐藤  
-- ユーザー3: ゲーム実況者山田
-- ユーザー4: 一般ユーザー

-- 2. contents テーブルのサンプルデータ
INSERT INTO contents (id, title, body, author, tags, category, user_id, privacy_level, created_at, updated_at)
VALUES 
  (1, 'iPhone 15 Pro Max 完全レビュー', 
   'AppleのフラッグシップモデルiPhone 15 Pro Maxを詳細にレビューします。カメラ性能、バッテリー持続時間、処理速度など、あらゆる角度から検証。特にProRAW撮影とAction Buttonの使い勝手について詳しく解説します。', 
   'テックレビューアー田中', 
   'iPhone,Apple,スマートフォン,レビュー,ガジェット', 
   'technology',
   '00000000-0000-0000-0000-000000000001',
   'public',
   NOW() - INTERVAL '2 hours',
   NOW() - INTERVAL '2 hours'),

  (2, '30分で作れる絶品パスタレシピ5選',
   '忙しい平日でも手軽に作れる美味しいパスタレシピを5つご紹介。トマトベース、クリームベース、オイルベースなど、バリエーション豊富なレシピで食卓を彩りましょう。材料は全てスーパーで手に入るものばかりです。',
   '料理研究家佐藤',
   'パスタ,レシピ,料理,イタリアン,簡単',
   'cooking',
   '00000000-0000-0000-0000-000000000002',
   'public',
   NOW() - INTERVAL '1 day',
   NOW() - INTERVAL '1 day'),

  (3, 'Flutter 3.0 新機能完全解説',
   'Flutter 3.0で追加された新機能を実際のコード例とともに詳しく解説します。Material Design 3対応、デスクトップサポートの改善、パフォーマンス向上など、開発者が知っておくべきポイントを網羅的にカバー。',
   'プログラミング講師伊藤',
   'Flutter,プログラミング,アプリ開発,Dart,モバイル',
   'programming',
   '00000000-0000-0000-0000-000000000003',
   'public',
   NOW() - INTERVAL '3 days',
   NOW() - INTERVAL '3 days'),

  (4, 'Apex Legends シーズン19 攻略ガイド',
   '最新シーズンの新キャラクター、武器バランス調整、マップ変更点を詳しく解説。ランクマッチで勝利するための戦略とテクニックも紹介します。初心者から上級者まで役立つ情報満載です。',
   'ゲーム実況者山田',
   'ApexLegends,ゲーム,FPS,攻略,ランクマッチ',
   'gaming',
   '00000000-0000-0000-0000-000000000004',
   'public',
   NOW() - INTERVAL '12 hours',
   NOW() - INTERVAL '12 hours'),

  (5, '投資初心者のための株式投資入門',
   '株式投資を始めたい方向けの基礎講座。証券口座の開き方から、銘柄選びのポイント、リスク管理まで分かりやすく説明します。長期投資の重要性と複利効果についても詳しく解説。',
   'ビジネス系YouTuber中村',
   '投資,株式,資産運用,金融,お金',
   'business',
   '00000000-0000-0000-0000-000000000005',
   'public',
   NOW() - INTERVAL '5 days',
   NOW() - INTERVAL '5 days'),

  (6, '自宅でできる筋トレメニュー完全版',
   '器具を使わずに自宅でできる効果的な筋トレメニューを紹介。部位別のトレーニング方法と正しいフォーム、頻度について詳しく解説します。初心者向けから上級者向けまで段階的にレベルアップできる内容です。',
   'フィットネストレーナー渡辺',
   '筋トレ,フィットネス,健康,運動,自宅トレーニング',
   'fitness',
   '00000000-0000-0000-0000-000000000006',
   'followers_only',
   NOW() - INTERVAL '1 day',
   NOW() - INTERVAL '1 day');

-- 3. tag_only_ingests テーブルのサンプルデータ
INSERT INTO tag_only_ingests (user_id, source_id, tag_hash, category, payload_json, created_at)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'youtube_001', 'hash_001', 'youtube',
   '{"title": "iPhone 15 Pro レビュー動画", "description": "最新iPhoneの詳細レビュー", "channel": "TechReviewer", "duration": "25:30", "tag": "ガジェットレビュー"}',
   NOW() - INTERVAL '3 hours'),

  ('00000000-0000-0000-0000-000000000002', 'youtube_002', 'hash_002', 'youtube',
   '{"title": "簡単パスタレシピ", "description": "忙しい日でも作れる美味しいパスタ", "channel": "CookingMaster", "duration": "12:45", "tag": "料理レシピ"}',
   NOW() - INTERVAL '1 day'),

  ('00000000-0000-0000-0000-000000000003', 'shopping_001', 'hash_003', 'shopping',
   '{"title": "MacBook Pro M3", "description": "プログラミング用ノートPC", "price": "¥298,000", "store": "Apple Store", "tag": "開発機材"}',
   NOW() - INTERVAL '2 days'),

  ('00000000-0000-0000-0000-000000000004', 'music_001', 'hash_004', 'music',
   '{"title": "YOASOBI - アイドル", "description": "人気楽曲", "artist": "YOASOBI", "album": "THE BOOK 3", "tag": "J-POP"}',
   NOW() - INTERVAL '4 hours'),

  ('00000000-0000-0000-0000-000000000001', 'app_001', 'hash_005', 'apps',
   '{"title": "Notion", "description": "生産性向上アプリ", "category": "仕事効率化", "rating": "4.8", "tag": "生産性"}',
   NOW() - INTERVAL '6 hours'),

  ('00000000-0000-0000-0000-000000000002', 'book_001', 'hash_006', 'books',
   '{"title": "人を動かす", "description": "デール・カーネギーの名著", "author": "デール・カーネギー", "genre": "自己啓発", "tag": "ビジネス書"}',
   NOW() - INTERVAL '8 hours');

-- 4. search_history テーブルのサンプルデータ
INSERT INTO search_history (user_id, query, search_type, created_at)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'iPhone 15', 'content', NOW() - INTERVAL '1 hour'),
  ('00000000-0000-0000-0000-000000000001', 'プログラミング', 'mixed', NOW() - INTERVAL '2 hours'),
  ('00000000-0000-0000-0000-000000000002', 'パスタ レシピ', 'content', NOW() - INTERVAL '30 minutes'),
  ('00000000-0000-0000-0000-000000000002', 'Flutter', 'content', NOW() - INTERVAL '3 hours'),
  ('00000000-0000-0000-0000-000000000003', 'Apex Legends', 'content', NOW() - INTERVAL '45 minutes'),
  ('00000000-0000-0000-0000-000000000003', 'ゲーム実況', 'mixed', NOW() - INTERVAL '1 day'),
  ('00000000-0000-0000-0000-000000000004', '投資', 'content', NOW() - INTERVAL '2 days'),
  ('00000000-0000-0000-0000-000000000004', '筋トレ', 'content', NOW() - INTERVAL '5 hours');

-- 5. user_follows テーブルのサンプルデータ
INSERT INTO user_follows (follower_user_id, followed_user_id, created_at)
VALUES 
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '1 week'),
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '5 days'),
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', NOW() - INTERVAL '3 days'),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', NOW() - INTERVAL '2 weeks'),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '1 week');

-- 6. 統計情報の更新
ANALYZE contents;
ANALYZE tag_only_ingests;
ANALYZE search_history;
ANALYZE user_follows;

COMMIT;