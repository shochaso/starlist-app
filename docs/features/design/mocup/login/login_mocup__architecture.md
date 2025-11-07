Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


\<\!DOCTYPE html\>  
\<html lang="ja"\>  
\<head\>  
    \<meta charset="UTF-8"\>  
    \<meta name="viewport" content="width=device-width, initial-scale=1.0"\>  
    \<title\>Starlist \- ログインフロー\</title\>  
    \<link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet"\>  
    \<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.4.0/css/all.min.css"\>  
    \<style\>  
        /\* 基本スタイル \*/  
        body {  
            font-family: \-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;  
            background-color: \#f9f9f9;  
            color: \#333;  
        }  
        /\* iOS風コンテナ \*/  
        .ios-container {  
            max-width: 390px; /\* iPhone 12/13 Proの幅に合わせる \*/  
            margin: 20px auto;  
            background: white;  
            border-radius: 30px; /\* iOS風の丸み \*/  
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);  
            overflow: hidden;  
            position: relative;  
        }  
        /\* iOS風ヘッダー \*/  
        .ios-header {  
            height: 44px; /\* iOSの標準的なヘッダー高さ \*/  
            background: white;  
            display: flex;  
            align-items: center;  
            justify-content: center;  
            position: relative;  
            border-bottom: 1px solid \#f1f1f1;  
        }  
        /\* iOS風コンテンツエリア \*/  
        .ios-content {  
            padding: 20px;  
            background: white;  
        }  
        /\* iOS風プライマリボタン \*/  
        .ios-button {  
            background: \#007AFF; /\* iOS標準ブルー \*/  
            color: white;  
            border-radius: 10px;  
            padding: 12px 20px;  
            width: 100%;  
            text-align: center;  
            font-weight: 600;  
            border: none;  
            cursor: pointer;  
            transition: all 0.2s;  
        }  
        .ios-button:hover {  
            background: \#0062cc; /\* ホバー時の色変化 \*/  
        }  
        /\* iOS風セカンダリボタン \*/  
        .ios-button.secondary {  
            background: \#E9E9EB; /\* iOSライトグレー \*/  
            color: \#007AFF;  
        }  
        .ios-button.secondary:hover {  
            background: \#d1d1d3;  
        }  
        /\* iOS風入力フィールド \*/  
        .ios-input {  
            border: 1px solid \#E9E9EB;  
            border-radius: 10px;  
            padding: 12px 15px;  
            width: 100%;  
            margin-bottom: 15px;  
            font-size: 16px;  
        }  
        .ios-input:focus {  
            border-color: \#007AFF;  
            outline: none;  
        }  
        /\* ソーシャルログインボタン \*/  
        .social-button {  
            display: flex;  
            align-items: center;  
            justify-content: center;  
            padding: 12px;  
            border-radius: 10px;  
            border: 1px solid \#E9E9EB;  
            background: white;  
            margin-bottom: 10px;  
            cursor: pointer;  
            transition: all 0.2s;  
        }  
        .social-button:hover {  
            background: \#f5f5f7;  
        }  
        /\* チェックボックスコンテナ \*/  
        .checkbox-container {  
            display: flex;  
            align-items: center;  
            margin: 10px 0;  
        }  
        .checkbox-container input {  
            margin-right: 10px;  
        }  
        /\* セクション区切り線 \*/  
        .section-divider {  
            margin: 60px 0;  
            border-top: 1px solid \#E9E9EB;  
            position: relative;  
        }  
        .section-divider::before {  
            content: attr(data-title); /\* data-title属性の内容を表示 \*/  
            position: absolute;  
            top: \-12px;  
            left: 50%;  
            transform: translateX(-50%);  
            background: white;  
            padding: 0 15px;  
            color: \#8E8E93; /\* iOSグレー \*/  
            font-size: 14px;  
        }  
        /\* フローインジケーター（ドット） \*/  
        .flow-indicator {  
            display: flex;  
            justify-content: center;  
            margin: 20px 0;  
        }  
        .flow-dot {  
            width: 8px;  
            height: 8px;  
            background: \#E9E9EB;  
            border-radius: 50%;  
            margin: 0 3px;  
        }  
        .flow-dot.active {  
            background: \#007AFF;  
        }  
        /\* ★修正: カードコンテナ（折り返し表示） \*/  
        .card-container {  
            display: flex;  
            flex-wrap: wrap; /\* 折り返しを有効に \*/  
            justify-content: flex-start; /\* 左寄せで配置 \*/  
            gap: 8px; /\* カード間の隙間 \*/  
            padding: 10px 0;  
            /\* margin: 0 \-10px; を削除 \*/  
            /\* overflow-x: auto; を削除 \*/  
            /\* scrollbar関連スタイルを削除 \*/  
        }

        /\* ★修正: ジャンル/スター/SNSカード共通スタイル \*/  
        .genre-card, .star-card, .sns-card {  
            /\* min-width: 120px; を削除 \*/  
            width: calc(25% \- 6px); /\* 4列表示 (gapを考慮) \*/  
            padding: 10px 5px; /\* パディングを調整 \*/  
            margin: 0; /\* マージンを削除 (gapで管理) \*/  
            border-radius: 12px;  
            background: \#f5f5f7;  
            text-align: center;  
            cursor: pointer;  
            transition: all 0.2s;  
            border: 1px solid transparent; /\* 選択時の枠線分のスペースを確保 \*/  
            box-sizing: border-box; /\* パディングとボーダーを幅に含める \*/  
        }  
        /\* ★修正: アイコンサイズ \*/  
        .sns-icon {  
            font-size: 20px; /\* アイコンサイズを少し小さく \*/  
            margin-bottom: 5px; /\* アイコンとテキストの間隔を調整 \*/  
            height: 24px; /\* 高さを固定して揃える \*/  
            display: flex;  
            align-items: center;  
            justify-content: center;  
            width: 100%;  
        }  
        /\* ★修正: カード内テキストサイズ \*/  
        .sns-card p {  
             font-size: 11px; /\* テキストサイズを小さく \*/  
             line-height: 1.2; /\* 行高調整 \*/  
             word-break: break-all; /\* 必要に応じて単語の途中でも改行 \*/  
             min-height: 2.4em; /\* テキストエリアの高さを確保 (2行分) \*/  
             display: flex;  
             align-items: center;  
             justify-content: center;  
        }

        /\* カードホバー/選択時スタイル \*/  
        .genre-card:hover, .star-card:hover, .sns-card:hover,  
        .genre-card.selected, .star-card.selected, .sns-card.selected {  
            background: \#E5F2FF; /\* ライトブルー \*/  
            border: 1px solid \#007AFF;  
        }  
        /\* カード選択時のチェックマーク \*/  
        .genre-card.selected, .star-card.selected, .sns-card.selected {  
            position: relative;  
        }  
        .genre-card.selected::after, .star-card.selected::after, .sns-card.selected::after {  
            content: '✓';  
            position: absolute;  
            top: 3px; /\* 位置調整 \*/  
            right: 3px; /\* 位置調整 \*/  
            background: \#007AFF;  
            color: white;  
            width: 16px; /\* サイズ調整 \*/  
            height: 16px; /\* サイズ調整 \*/  
            border-radius: 50%;  
            display: flex;  
            align-items: center;  
            justify-content: center;  
            font-size: 10px; /\* サイズ調整 \*/  
        }  
        /\* スターカード内の画像 \*/  
        .star-card img {  
            width: 60px;  
            height: 60px;  
            border-radius: 30px; /\* 円形 \*/  
            margin: 0 auto 10px;  
            object-fit: cover; /\* 画像のアスペクト比を維持 \*/  
        }  
        /\* ステップインジケーター \*/  
        .step-indicator {  
            background: \#f5f5f7;  
            color: \#8E8E93;  
            padding: 3px 10px;  
            border-radius: 15px;  
            font-size: 12px;  
            display: inline-block;  
            margin-bottom: 5px;  
        }  
        /\* 通知カード \*/  
        .notification-card {  
            background: \#F2F2F7; /\* iOS設定画面風グレー \*/  
            border-radius: 12px;  
            padding: 15px;  
            margin: 20px 0;  
        }

        /\* 年齢選択用スタイル \*/  
        .age-selector {  
            display: flex;  
            justify-content: space-between;  
            margin-bottom: 10px; /\* ボタン間の間隔を調整 \*/  
        }

        .age-range {  
            padding: 12px 10px;  
            border-radius: 10px;  
            background: \#f5f5f7;  
            text-align: center;  
            flex: 1; /\* 利用可能なスペースを均等に分割 \*/  
            margin: 0 4px; /\* ボタン間の間隔 \*/  
            cursor: pointer;  
            transition: all 0.2s;  
            font-size: 14px; /\* フォントサイズ \*/  
            border: 1px solid transparent; /\* 選択時の枠線スペース確保 \*/  
            white-space: nowrap; /\* テキストが折り返さないようにする \*/  
        }

        .age-range:hover, .age-range.selected {  
            background: \#E5F2FF;  
            border: 1px solid \#007AFF;  
        }

        .age-range.selected {  
            position: relative;  
        }

        .age-range.selected::after {  
            content: '✓';  
            position: absolute;  
            top: 5px;  
            right: 5px;  
            background: \#007AFF;  
            color: white;  
            width: 20px;  
            height: 20px;  
            border-radius: 50%;  
            display: flex;  
            align-items: center;  
            justify-content: center;  
            font-size: 12px;  
        }

        /\* Xロゴスタイル \*/  
        .x-logo {  
            font-weight: bold;  
            font-size: 1.2em; /\* アイコンサイズに合わせる \*/  
        }

        /\* 簡素化されたフローインジケーター (円形) \*/  
        .flow-nav {  
            display: flex;  
            justify-content: center;  
            padding: 15px 0 5px; /\* 上下のパディング調整 \*/  
        }

        .flow-circle {  
            width: 6px; /\* ドットより少し小さめ \*/  
            height: 6px;  
            border-radius: 50%;  
            margin: 0 4px;  
            background-color: \#ddd; /\* 未完了の色 \*/  
        }

        .flow-circle.active {  
            background-color: \#007AFF; /\* 現在のステップの色 \*/  
        }

        .flow-circle.completed {  
            background-color: \#34C759; /\* 完了したステップの色 (iOSグリーン) \*/  
        }  
    \</style\>  
\</head\>  
\<body\>  
    \<div class="main-content"\>  
        \<div class="ios-container"\>  
            \<div class="ios-header"\>  
                \<h2 class="text-xl font-bold"\>Starlist\</h2\>  
            \</div\>  
            \<div class="ios-content"\>  
                \<div class="text-center mb-8"\>  
                    \<div class="w-20 h-20 bg-blue-500 rounded-2xl mx-auto mb-4 flex items-center justify-center"\>  
                        \<i class="fas fa-star text-white text-3xl"\>\</i\>  
                    \</div\>  
                    \<h1 class="text-2xl font-bold mb-2"\>Starlistへようこそ\</h1\>  
                    \<p class="text-gray-500"\>スターの日常をもっと身近に\</p\>  
                \</div\>

                \<form\>  
                    \<input type="email" class="ios-input" placeholder="メールアドレスまたはユーザー名"\>  
                    \<input type="password" class="ios-input" placeholder="パスワード"\>  
                    \<button type="button" class="ios-button mb-4"\>ログイン\</button\>  
                \</form\>

                \<div class="text-center mb-4"\>  
                    \<a href="\#password-reset" class="text-blue-500"\>パスワードをお忘れですか？\</a\>  
                \</div\>

                \<div class="text-center mb-6"\>  
                    \<a href="\#create-account" class="text-blue-500 font-semibold"\>アカウントを作成\</a\>  
                \</div\>

                \<div class="section-divider" data-title="または"\>\</div\>

                \<div class="mt-6"\>  
                    \<div class="social-button"\>  
                        \<i class="fab fa-google mr-3 text-red-500"\>\</i\>  
                        Googleでログイン  
                    \</div\>  
                    \<div class="social-button"\>  
                        \<span class="x-logo mr-3 text-black"\>𝕏\</span\>  
                        Xでログイン  
                    \</div\>  
                    \<div class="social-button"\>  
                        \<i class="fab fa-facebook mr-3 text-blue-600"\>\</i\>  
                        Facebookでログイン  
                    \</div\>  
                \</div\>

                \<div class="mt-8 text-center"\>  
                    \<p class="text-gray-500 text-sm"\>ログインすることで、Starlistの\<a href="\#" class="text-blue-500"\>利用規約\</a\>および\<a href="\#" class="text-blue-500"\>プライバシーポリシー\</a\>に同意したことになります。\</p\>  
                \</div\>  
            \</div\>  
        \</div\>

        \<div class="section-divider" data-title="パスワード再設定フロー"\>\</div\>  
        \<div class="ios-container"\>  
             \<div class="ios-header"\>  
                \<a href="\#" class="absolute left-4 text-blue-500"\>キャンセル\</a\>  
                \<h2 class="text-lg font-semibold"\>パスワード再設定\</h2\>  
            \</div\>  
            \<div class="ios-content"\>  
                \<div class="step-indicator"\>ステップ 1/2\</div\>  
                \<h2 class="text-xl font-bold mb-4"\>メールアドレス確認\</h2\>  
                \<p class="text-gray-500 mb-6"\>アカウントに登録したメールアドレスを入力してください。パスワード再設定のための確認コードを送信します。\</p\>  
                \<form\>  
                    \<input type="email" class="ios-input" placeholder="登録済みのメールアドレス"\>  
                    \<button type="button" class="ios-button mb-4"\>確認コードを送信\</button\>  
                \</form\>  
                \<div class="notification-card"\>  
                    \<div class="flex items-start"\>  
                        \<i class="fas fa-info-circle text-blue-500 mt-1 mr-3"\>\</i\>  
                        \<p class="text-sm"\>登録したメールアドレスが分からない場合は、\<a href="\#" class="text-blue-500"\>カスタマーサポート\</a\>までお問い合わせください。\</p\>  
                    \</div\>  
                \</div\>  
            \</div\>  
            \<div class="flow-indicator"\>  
                \<div class="flow-dot active"\>\</div\>  
                \<div class="flow-dot"\>\</div\>  
            \</div\>  
        \</div\>  
        \<div class="ios-container mt-10"\>  
             \<div class="ios-header"\>  
                \<a href="\#" class="absolute left-4 text-blue-500"\>戻る\</a\>  
                \<h2 class="text-lg font-semibold"\>パスワード再設定\</h2\>  
            \</div\>  
            \<div class="ios-content"\>  
                \<div class="step-indicator"\>ステップ 2/2\</div\>  
                \<h2 class="text-xl font-bold mb-4"\>新しいパスワードを設定\</h2\>  
                \<p class="text-gray-500 mb-6"\>安全なパスワードを設定してください。8文字以上で、英数字を含める必要があります。\</p\>  
                \<form\>  
                    \<input type="password" class="ios-input" placeholder="新しいパスワード"\>  
                    \<div class="mb-4"\>  
                        \<div class="flex items-center justify-between mb-1"\>  
                            \<span class="text-xs text-gray-500"\>パスワード強度:\</span\>  
                            \<span class="text-xs text-green-500"\>強い\</span\>  
                        \</div\>  
                        \<div class="w-full h-1 bg-gray-200 rounded-full"\>  
                            \<div class="w-full h-1 bg-green-500 rounded-full"\>\</div\>  
                        \</div\>  
                    \</div\>  
                    \<input type="password" class="ios-input" placeholder="パスワードを確認"\>  
                    \<button type="button" class="ios-button mb-4"\>パスワードを更新\</button\>  
                \</form\>  
                \<div class="bg-gray-50 p-4 rounded-lg"\>  
                    \<h3 class="text-sm font-semibold mb-2"\>安全なパスワードの条件:\</h3\>  
                    \<ul class="text-xs text-gray-500"\>  
                        \<li class="flex items-center mb-1"\>\<i class="fas fa-check text-green-500 mr-2"\>\</i\> 8文字以上\</li\>  
                        \<li class="flex items-center mb-1"\>\<i class="fas fa-check text-green-500 mr-2"\>\</i\> 英大文字と小文字を含む\</li\>  
                        \<li class="flex items-center mb-1"\>\<i class="fas fa-check text-green-500 mr-2"\>\</i\> 数字を含む\</li\>  
                    \</ul\>  
                \</div\>  
            \</div\>  
            \<div class="flow-indicator"\>  
                \<div class="flow-dot"\>\</div\>  
                \<div class="flow-dot active"\>\</div\>  
            \</div\>  
        \</div\>

        \<div class="section-divider" data-title="新規アカウント作成フロー"\>\</div\>

        \<div class="ios-container"\>  
            \<div class="ios-header"\>  
                \<a href="\#" class="absolute left-4 text-blue-500"\>キャンセル\</a\>  
                \<h2 class="text-lg font-semibold"\>アカウント作成\</h2\>  
            \</div\>  
            \<div class="flow-nav"\>  
                \<div class="flow-circle active"\>\</div\>  
                \<div class="flow-circle"\>\</div\>  
                \<div class="flow-circle"\>\</div\>  
                \<div class="flow-circle"\>\</div\>  
            \</div\>  
            \<div class="ios-content"\>  
                \<div class="step-indicator"\>ステップ 1/4\</div\>  
                \<h2 class="text-xl font-bold mb-4"\>基本情報を入力\</h2\>  
                \<p class="text-gray-500 mb-6"\>Starlistアカウントを作成するために必要な情報を入力してください。\</p\>  
                \<form\>  
                    \<input type="text" class="ios-input" placeholder="ユーザーネーム"\>  
                    \<input type="text" class="ios-input" placeholder="表示名"\>  
                    \<input type="email" class="ios-input" placeholder="メールアドレス"\>  
                    \<input type="password" class="ios-input" placeholder="パスワード（8文字以上）"\>  
                    \<div class="checkbox-container mb-6"\>  
                        \<input type="checkbox" id="marketing-consent"\>  
                        \<label for="marketing-consent" class="text-sm text-gray-500"\>Starlistからのお知らせやキャンペーン情報を受け取る\</label\>  
                    \</div\>  
                    \<button type="button" class="ios-button mb-4"\>次へ\</button\>  
                \</form\>  
                \<div class="text-center mt-4"\>  
                    \<p class="text-sm text-gray-500"\>すでにアカウントをお持ちですか？ \<a href="\#" class="text-blue-500"\>ログイン\</a\>\</p\>  
                \</div\>  
            \</div\>  
        \</div\>

        \<div class="ios-container mt-10"\>  
            \<div class="ios-header"\>  
                \<a href="\#" class="absolute left-4 text-blue-500"\>戻る\</a\>  
                \<h2 class="text-lg font-semibold"\>アカウント作成\</h2\>  
            \</div\>  
            \<div class="flow-nav"\>  
                \<div class="flow-circle completed"\>\</div\>  
                \<div class="flow-circle active"\>\</div\>  
                \<div class="flow-circle"\>\</div\>  
                \<div class="flow-circle"\>\</div\>  
            \</div\>  
            \<div class="ios-content"\>  
                \<div class="step-indicator"\>ステップ 2/4\</div\>  
                \<h2 class="text-xl font-bold mb-4"\>年齢確認\</h2\>  
                \<p class="text-gray-500 mb-6"\>あなたの年齢層を教えてください。より良いコンテンツをお届けするために使用されます。\</p\>  
                \<div class="age-selector"\>  
                    \<div class="age-range"\>10代\</div\>  
                    \<div class="age-range selected"\>20代\</div\>  
                    \<div class="age-range"\>30代\</div\>  
                    \<div class="age-range"\>40代\</div\>  
                \</div\>  
                \<div class="age-selector"\>  
                    \<div class="age-range"\>50代\</div\>  
                    \<div class="age-range"\>60代\</div\>  
                    \<div class="age-range"\>70代+\</div\>  
                    \<div class="age-range"\>回答しない\</div\>  
                \</div\>  
                \<div class="mt-6 mb-6"\>  
                    \<p class="text-xs text-gray-500 mb-2"\>※年齢情報は個人を特定するために使用されることはありません。\</p\>  
                    \<p class="text-xs text-gray-500"\>※あなたに合ったコンテンツの推奨やサービス改善のために活用されます。\</p\>  
                \</div\>  
                \<button type="button" class="ios-button mb-4"\>次へ\</button\>  
            \</div\>  
        \</div\>

        \<div class="ios-container mt-10"\>  
            \<div class="ios-header"\>  
                \<a href="\#" class="absolute left-4 text-blue-500"\>戻る\</a\>  
                \<h2 class="text-lg font-semibold"\>アカウント作成\</h2\>  
            \</div\>

            \<div class="flow-nav"\>  
                \<div class="flow-circle completed"\>\</div\>  
                \<div class="flow-circle completed"\>\</div\>  
                \<div class="flow-circle active"\>\</div\> \<div class="flow-circle"\>\</div\>  
            \</div\>

            \<div class="ios-content"\>  
                \<div class="step-indicator"\>ステップ 3/4\</div\>  
                \<h2 class="text-xl font-bold mb-4"\>普段利用するサービス\</h2\>  
                \<p class="text-gray-500 mb-6"\>普段利用するSNSや配信サイトを選択してください。連携機能の向上に役立ちます。（複数選択可）\</p\>

                \<h3 class="text-base font-semibold mb-2"\>SNS\</h3\>  
                \<div class="card-container"\>  
                    \<div class="sns-card selected"\>  
                        \<div class="sns-icon text-black"\>\<span class="x-logo"\>𝕏\</span\>\</div\>  
                        \<p\>X\</p\>  
                    \</div\>  
                    \<div class="sns-card selected"\>  
                        \<div class="sns-icon text-blue-600"\>\<i class="fab fa-facebook"\>\</i\>\</div\>  
                        \<p\>Facebook\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-black"\>\<i class="fas fa-mobile-alt"\>\</i\>\</div\>  
                        \<p\>BeReal\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-blue-500"\>\<i class="fas fa-at"\>\</i\>\</div\>  
                        \<p\>Threads\</p\>  
                    \</div\>  
                    \</div\>

                \<h3 class="text-base font-semibold mb-2 mt-4"\>動画/配信サイト\</h3\>  
                \<div class="card-container"\>  
                    \<div class="sns-card selected"\>  
                        \<div class="sns-icon text-red-600"\>\<i class="fab fa-youtube"\>\</i\>\</div\>  
                        \<p\>YouTube\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-pink-500"\>\<i class="fab fa-instagram"\>\</i\>\</div\>  
                        \<p\>Instagram\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-pink-600"\>\<i class="fab fa-tiktok"\>\</i\>\</div\>  
                        \<p\>TikTok\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-purple-600"\>\<i class="fab fa-twitch"\>\</i\>\</div\>  
                        \<p\>Twitch\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-blue-400"\>\<i class="fas fa-microphone"\>\</i\>\</div\>  
                        \<p\>ツイキャス\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-pink-500"\>\<i class="fas fa-video"\>\</i\>\</div\>  
                        \<p\>ふわっち\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-green-500"\>\<i class="fas fa-tree"\>\</i\>\</div\>  
                        \<p\>Palmu\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-blue-400"\>\<i class="fas fa-broadcast-tower"\>\</i\>\</div\>  
                        \<p\>TwitCasting\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-red-500"\>\<i class="fas fa-tv"\>\</i\>\</div\>  
                        \<p\>SHOWROOM\</p\>  
                    \</div\>  
                     \<div class="sns-card selected"\>  
                        \<div class="sns-icon text-purple-500"\>\<i class="fas fa-video"\>\</i\>\</div\>  
                        \<p\>17LIVE\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-green-400"\>\<i class="fas fa-laugh"\>\</i\>\</div\>  
                        \<p\>ニコニコ\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-green-500"\>\<i class="fab fa-line"\>\</i\>\</div\>  
                        \<p\>LINE LIVE\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-blue-500"\>\<i class="fas fa-gamepad"\>\</i\>\</div\>  
                        \<p\>Mildom\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-orange-500"\>\<i class="fas fa-play-circle"\>\</i\>\</div\>  
                        \<p\>OPENREC\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-blue-400"\>\<i class="fas fa-mobile-alt"\>\</i\>\</div\>  
                        \<p\>Mirrativ\</p\>  
                    \</div\>  
                    \<div class="sns-card"\>  
                        \<div class="sns-icon text-indigo-500"\>\<i class="fas fa-vr-cardboard"\>\</i\>\</div\>  
                        \<p\>REALITY\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-pink-400"\>\<i class="fas fa-smile"\>\</i\>\</div\>  
                        \<p\>IRIAM\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-blue-600"\>\<i class="fas fa-globe"\>\</i\>\</div\>  
                        \<p\>BIGO LIVE\</p\>  
                    \</div\>  
                    \<div class="sns-card selected"\>  
                        \<div class="sns-icon text-yellow-500"\>\<i class="fas fa-microphone"\>\</i\>\</div\>  
                        \<p\>Spoon\</p\>  
                    \</div\>  
                    \<div class="sns-card selected"\>  
                        \<div class="sns-icon text-pink-300"\>\<i class="fas fa-heart"\>\</i\>\</div\>  
                        \<p\>Pococha\</p\>  
                    \</div\>  
                     \<div class="sns-card"\>  
                        \<div class="sns-icon text-orange-500"\>\<i class="fas fa-comment"\>\</i\>\</div\>  
                        \<p\>TangoMe\</p\>  
                    \</div\>  
                     \</div\>

                \<div class="text-center my-6"\>  
                    \<span id="selected-count" class="text-sm text-gray-500"\>5個選択中\</span\> \</div\>

                \<button type="button" class="ios-button mb-4"\>次へ\</button\>  
            \</div\>  
        \</div\>

        \<div class="ios-container mt-10"\>  
            \<div class="ios-header"\>  
                \<a href="\#" class="absolute left-4 text-blue-500"\>戻る\</a\>  
                \<h2 class="text-lg font-semibold"\>アカウント作成\</h2\>  
            \</div\>

            \<div class="flow-nav"\>  
                \<div class="flow-circle completed"\>\</div\>  
                \<div class="flow-circle completed"\>\</div\>  
                \<div class="flow-circle completed"\>\</div\>  
                \<div class="flow-circle active"\>\</div\> \</div\>

            \<div class="ios-content"\>  
                 \<div class="step-indicator"\>ステップ 4/4\</div\>  
                \<h2 class="text-xl font-bold mb-4"\>利用規約と個人情報保護方針\</h2\>  
                \<p class="text-gray-500 mb-6"\>続行する前に、下記の規約をご確認ください。\</p\>

                \<div class="bg-gray-50 p-4 rounded-lg mb-6 h-48 overflow-y-auto"\>  
                    \<h3 class="font-semibold mb-2"\>Starlist利用規約\</h3\>  
                    \<p class="text-xs text-gray-500 mb-3"\>最終更新日: 2023年4月1日\</p\>  
                    \<p class="text-sm text-gray-600 mb-2"\>1. はじめに\</p\>  
                    \<p class="text-xs text-gray-500 mb-3"\>Starlist（以下「本サービス」）をご利用いただきありがとうございます。本利用規約（以下「本規約」）は、ユーザーと当社との間の法的合意を構成し、本サービスの利用に適用されます。\</p\>  
                    \<p class="text-sm text-gray-600 mb-2"\>2. アカウント\</p\>  
                    \<p class="text-xs text-gray-500 mb-3"\>本サービスを利用するには、アカウントの作成が必要です。アカウント情報の保護はユーザーの責任となります。\</p\>  
                    \<p class="text-sm text-gray-600 mb-2"\>3. プライバシー\</p\>  
                    \<p class="text-xs text-gray-500 mb-3"\>当社のプライバシーポリシーは、本サービスの利用に伴い当社が収集するデータとその使用方法について説明しています。\</p\>  
                    \<p class="text-sm text-gray-600 mb-2"\>4. コンテンツとライセンス\</p\>  
                    \<p class="text-xs text-gray-500 mb-3"\>ユーザーは、本サービスに投稿するコンテンツの所有権を保持しますが、当社に対して世界的、非独占的、ロイヤリティフリーのライセンスを付与します。\</p\>  
                    \<p class="text-sm text-gray-600 mb-2"\>5. 禁止行為\</p\>  
                    \<p class="text-xs text-gray-500 mb-3"\>違法なコンテンツの投稿、他のユーザーへの嫌がらせ、サービスの機能を妨害する行為は禁止されています。\</p\>  
                    \</div\>

                \<div class="checkbox-container mb-4"\>  
                    \<input type="checkbox" id="terms-consent-final"\> \<label for="terms-consent-final" class="text-sm"\>\<span class="text-gray-800 font-medium"\>利用規約\</span\>に同意します\</label\>  
                \</div\>

                \<div class="checkbox-container mb-6"\>  
                    \<input type="checkbox" id="privacy-consent-final"\> \<label for="privacy-consent-final" class="text-sm"\>\<span class="text-gray-800 font-medium"\>個人情報保護方針\</span\>に同意します\</label\>  
                \</div\>

                \<button type="button" class="ios-button mb-4"\>同意してアカウント作成\</button\> \</div\>  
        \</div\>

        \<div class="ios-container mt-10"\>  
            \<div class="ios-header"\>  
                \<h2 class="text-lg font-semibold"\>アカウント作成完了\</h2\>  
            \</div\>  
            \<div class="ios-content"\>  
                \<div class="text-center mb-8"\>  
                    \<div class="w-20 h-20 bg-green-500 rounded-full mx-auto mb-4 flex items-center justify-center"\>  
                        \<i class="fas fa-check text-white text-3xl"\>\</i\>  
                    \</div\>  
                    \<h1 class="text-2xl font-bold mb-2"\>アカウント設定完了\!\</h1\>  
                    \<p class="text-gray-500"\>Starlistへようこそ\</p\>  
                \</div\>  
                \<div class="bg-blue-50 p-4 rounded-lg mb-6"\>  
                    \<div class="flex items-start"\>  
                        \<i class="fas fa-info-circle text-blue-500 mt-1 mr-3"\>\</i\>  
                        \<p class="text-sm"\>あなたの好みに基づいたコンテンツをホーム画面に表示しています。ぜひチェックしてみてください。\</p\>  
                    \</div\>  
                \</div\>  
                \<div class="notification-card"\>  
                    \<h3 class="font-semibold mb-2"\>次のステップ\</h3\>  
                    \<ul class="text-sm text-gray-600"\>  
                        \<li class="flex items-center mb-3"\>  
                            \<i class="fas fa-user-circle text-blue-500 mr-2"\>\</i\>  
                            プロフィールを完成させる  
                        \</li\>  
                        \<li class="flex items-center mb-3"\>  
                            \<i class="fas fa-star text-blue-500 mr-2"\>\</i\>  
                            好きなスターをフォローする  
                        \</li\>  
                        \<li class="flex items-center"\>  
                            \<i class="fas fa-bell text-blue-500 mr-2"\>\</i\>  
                            通知設定を確認する  
                        \</li\>  
                    \</ul\>  
                \</div\>  
                \<button type="button" class="ios-button mt-6 mb-4"\>ホームに進む\</button\>  
            \</div\>  
        \</div\>  
    \</div\>

    \<script\>  
        document.addEventListener('DOMContentLoaded', function() {  
            // \--- 選択状態の切り替え \---  
            const selectableCards \= document.querySelectorAll('.genre-card, .star-card, .sns-card');  
            const selectedCountElement \= document.getElementById('selected-count'); // 選択数表示要素

            // 選択数を更新する関数  
            function updateSelectedCount() {  
                const count \= document.querySelectorAll('.sns-card.selected').length;  
                if (selectedCountElement) {  
                    selectedCountElement.textContent \= \`${count}個選択中\`;  
                }  
            }

            // サービスカード (複数選択)  
            selectableCards.forEach(card \=\> {  
                // sns-cardのみを対象とする  
                if (card.classList.contains('sns-card')) {  
                     card.addEventListener('click', function() {  
                        this.classList.toggle('selected');  
                        updateSelectedCount(); // 選択数を更新  
                    });  
                } else {  
                     // sns-card 以外 (genre-card, star-card \- もしあれば)  
                     card.addEventListener('click', function() {  
                        this.classList.toggle('selected');  
                    });  
                }  
            });

             // 年齢範囲 (単一選択)  
            const ageRanges \= document.querySelectorAll('.age-range');  
            ageRanges.forEach(range \=\> {  
                range.addEventListener('click', function() {  
                    ageRanges.forEach(r \=\> r.classList.remove('selected'));  
                    this.classList.add('selected');  
                });  
            });

            // 初期選択数を表示 (ページ読み込み時)  
            updateSelectedCount();  
        });  
    \</script\>  
\</body\>  
\</html\>

