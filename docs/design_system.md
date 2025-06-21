# Starlist デザインシステム

## 🎨 カラーパレット

### プライマリカラー
```css
--primary-blue: #007AFF;
--primary-blue-hover: #0062cc;
--primary-blue-light: #E5F2FF;
```

### セカンダリカラー
```css
--background-primary: #f8f9fa;
--background-secondary: #f5f5f7;
--card-background: #ffffff;
--text-primary: #333333;
--text-secondary: #8E8E93;
--border-color: #E9E9EB;
```

### ステータスカラー
```css
--success: #34C759;
--error: #FF3B30;
--warning: #FF9500;
--info: #007AFF;
```

### グラデーション
```css
--gradient-purple: linear-gradient(to bottom right, #6366F1, #A855F7);
--gradient-blue: linear-gradient(to bottom right, #3B82F6, #0EA5E9);
--gradient-green: linear-gradient(to bottom right, #10B981, #059669);
--gradient-red: linear-gradient(to bottom right, #EF4444, #E11D48);
```

## 📝 タイポグラフィ

### フォントファミリー
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
```

### フォントサイズ
- **見出し1**: 24px / font-weight: 700
- **見出し2**: 20px / font-weight: 600
- **見出し3**: 18px / font-weight: 600
- **本文**: 16px / font-weight: 400
- **キャプション**: 14px / font-weight: 400
- **小文字**: 12px / font-weight: 400

## 🔲 レイアウト

### スペーシング
```css
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 12px;
--spacing-lg: 16px;
--spacing-xl: 20px;
--spacing-2xl: 24px;
--spacing-3xl: 32px;
```

### 角丸
```css
--radius-sm: 8px;
--radius-md: 10px;
--radius-lg: 12px;
--radius-xl: 16px;
--radius-2xl: 20px;
--radius-full: 50%;
--radius-container: 30px;
```

### シャドウ
```css
--shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.1);
--shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
--shadow-lg: 0 4px 20px rgba(0, 0, 0, 0.1);
--shadow-xl: 0 10px 25px rgba(0, 0, 0, 0.15);
```

## 🧩 コンポーネント

### ボタン
```dart
// プライマリボタン
Container(
  decoration: BoxDecoration(
    color: Color(0xFF007AFF),
    borderRadius: BorderRadius.circular(10),
  ),
  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  child: Text('ボタン', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
)
```

### カード
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: // コンテンツ
)
```

### 入力フィールド
```dart
TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0xFFE9E9EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0xFF007AFF)),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
  ),
)
```

## 📱 レスポンシブブレークポイント

```dart
class ScreenSizes {
  static const double mobile = 390;
  static const double tablet = 768;
  static const double desktop = 1024;
}
```

## 🎭 アニメーション

### デュレーション
```dart
const Duration fastAnimation = Duration(milliseconds: 150);
const Duration normalAnimation = Duration(milliseconds: 200);
const Duration slowAnimation = Duration(milliseconds: 300);
```

### カーブ
```dart
const Curve defaultCurve = Curves.easeInOut;
const Curve bounceCurve = Curves.elasticOut;
```

## 🌙 ダークモード対応

### ダークカラー
```css
--dark-background-primary: #000000;
--dark-background-secondary: #1C1C1E;
--dark-card-background: #2C2C2E;
--dark-text-primary: #FFFFFF;
--dark-text-secondary: #8E8E93;
```

## ♿ アクセシビリティ

### 最小タッチターゲット
- **ボタン**: 44x44px 以上
- **タップ可能要素**: 48x48px 推奨

### コントラスト比
- **通常テキスト**: 4.5:1 以上
- **大きなテキスト**: 3:1 以上

### セマンティクス
```dart
Semantics(
  label: '説明テキスト',
  button: true,
  child: // ウィジェット
)
``` 