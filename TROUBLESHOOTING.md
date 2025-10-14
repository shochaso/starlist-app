# トラブルシューティングガイド

## 🚨 起動に失敗する場合

### 症状: `c`コマンドで起動しない

#### ステップ1: ログを確認
```bash
# Flutterのログ
tail -f logs/flutter.log

# BrowserSyncのログ
tail -f logs/browsersync.log
```

#### ステップ2: 一般的な原因と対策

##### 1️⃣ **pubspec.yamlの構文エラー**
**原因**: YAMLファイルに重複キーや構文エラーがある

**確認方法**:
```bash
flutter pub get
```

**エラー例**:
```
Error on line 44, column 3: Duplicate mapping key.
```

**対策**:
- `pubspec.yaml`を開いて、重複しているキーを削除
- インデントが正しいか確認（スペース2個）
- コロン（:）の後にスペースがあるか確認

##### 2️⃣ **ポート衝突**
**原因**: 8080または3000ポートが既に使用されている

**確認方法**:
```bash
lsof -i :8080
lsof -i :3000
```

**対策**:
```bash
# プロセスを停止
pkill -f flutter
pkill -f browser-sync

# または特定のPIDを停止
kill -9 <PID>
```

##### 3️⃣ **Chromeが起動しない**
**原因**: Chromeが見つからない、または権限の問題

**確認方法**:
```bash
flutter devices
```

**対策**:
- Chromeがインストールされているか確認
- Chromeを一度手動で起動してみる
- `flutter config --enable-web`を実行

##### 4️⃣ **依存関係の問題**
**原因**: パッケージのバージョン衝突

**対策**:
```bash
# キャッシュをクリア
flutter clean
flutter pub cache repair
flutter pub get

# Node.jsパッケージもクリア
rm -rf node_modules package-lock.json
npm install
```

##### 5️⃣ **ビルドエラー**
**原因**: Dartコードにコンパイルエラーがある

**確認方法**:
```bash
flutter analyze
```

**対策**:
- エラーメッセージを読んで該当ファイルを修正
- `logs/flutter.log`で詳細を確認

#### ステップ3: 完全リセット

全てが失敗した場合:

```bash
# 1. 全プロセス停止
pkill -f flutter
pkill -f browser-sync
pkill -f dart
pkill -f Chrome

# 2. キャッシュクリア
flutter clean
rm -rf .dart_tool
rm -rf build
rm -rf node_modules
rm -rf logs

# 3. 再インストール
flutter pub get
npm install

# 4. 再起動
./scripts/c.sh
```

---

## 📊 ログファイルの見方

### Flutter ログ (`logs/flutter.log`)

#### 正常な起動:
```
Launching lib/main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...
Debug service listening on ws://127.0.0.1:xxxxx
```

#### エラー例:
```
Error: Getter not found: 'someVariable'
Could not resolve the package 'package_name'
```

### BrowserSync ログ (`logs/browsersync.log`)

#### 正常な起動:
```
[Browsersync] Proxying: http://localhost:8080
[Browsersync] Access URLs:
       Local: http://localhost:3000
```

---

## 🔧 予防策

### 1. 定期的なメンテナンス
```bash
# 週に1回実行推奨
flutter pub upgrade
npm update
flutter clean
```

### 2. Git hooks設定
`.git/hooks/pre-commit`に以下を追加:
```bash
#!/bin/sh
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Flutter analyze failed!"
  exit 1
fi
```

### 3. pubspec.yamlの検証
依存関係を追加する際:
```bash
# 手動編集後は必ず実行
flutter pub get

# エラーがないか確認
flutter analyze
```

---

## 🆘 それでも解決しない場合

### ログを保存して報告
```bash
# 診断情報を収集
flutter doctor -v > diagnosis.txt
cat logs/flutter.log >> diagnosis.txt
cat logs/browsersync.log >> diagnosis.txt
cat pubspec.yaml >> diagnosis.txt
```

### よくある質問

**Q: なぜ8080ポートと3000ポートの両方が必要？**
A: 
- 8080: Flutter開発サーバー（ホットリロード）
- 3000: BrowserSync（高速リロード + デバッグツール）

**Q: 直接8080にアクセスできない？**
A: できますが、BrowserSync経由（3000）の方が高速で安定しています。

**Q: `c`コマンドの代わりに直接flutterコマンドを使える？**
A: 可能ですが、ログ管理やエラー検出がないため推奨しません。

---

## 📚 参考リンク

- [Flutter Web ドキュメント](https://docs.flutter.dev/get-started/web)
- [BrowserSync ドキュメント](https://browsersync.io/docs)
- [pubspec.yaml 仕様](https://dart.dev/tools/pub/pubspec)

