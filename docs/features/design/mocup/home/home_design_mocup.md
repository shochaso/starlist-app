---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


\<\!DOCTYPE html\>  
\<html lang="ja"\>  
\<head\>  
    \<meta charset="UTF-8"\>  
    \<meta name="viewport" content="width=device-width, initial-scale=1.0"\>  
    \<title\>Starlist \- HOME\</title\>  
    \<script src="https://cdn.tailwindcss.com"\>\</script\>  
    \<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet"\>  
    \<style\>  
        /\* モバイルファーストのスタイリング \*/  
        body {  
            font-family: 'Inter', sans-serif;  
        }  
        .mobile-header {  
            background: rgba(255, 255, 255, 0.95);  
            \-webkit-backdrop-filter: blur(10px);  
            backdrop-filter: blur(10px);  
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);  
            z-index: 100;  
            transition: transform 0.3s ease;  
        }

        .mobile-header.hidden {  
            transform: translateY(-100%);  
        }

        .bottom-nav {  
            background: white;  
            border-top: 1px solid \#e5e7eb;  
            box-shadow: 0 \-2px 10px rgba(0, 0, 0, 0.1);  
            height: 70px;   
            z-index: 100;  
        }

        .nav-item {  
            display: flex;  
            flex-direction: column;  
            align-items: center;  
            justify-content: center;  
            padding: 8px 4px;  
            color: \#9ca3af;  
            transition: color 0.2s ease;  
            flex: 1;  
            min-width: 0;  
        }

        .nav-item.active { color: \#3b82f6; }  
        .nav-item:hover { color: \#6b7280; }

        .nav-item i {  
            font-size: 20px;  
            margin-bottom: 3px;  
        }

        .nav-item span {  
            font-size: 11px;  
            font-weight: 500;  
            white-space: nowrap;  
            overflow: hidden;  
            text-overflow: ellipsis;  
            max-width: 100%;  
        }

        .youtube-history-hero {  
            background: linear-gradient(135deg, \#667eea 0%, \#764ba2 100%);  
            border-radius: 20px;  
            padding: 24px;  
            margin-bottom: 24px;  
            color: white;  
            position: relative;  
            overflow: hidden;  
        }

        .youtube-history-hero::before {  
            content: '';  
            position: absolute;  
            top: 0;  
            right: 0;  
            width: 100px;  
            height: 100px;  
            background: rgba(255, 255, 255, 0.1);  
            border-radius: 50%;  
            transform: translate(30px, \-30px);  
        }

        .video-hero-card {  
            background: white;  
            border-radius: 16px;  
            padding: 16px;  
            margin-bottom: 16px;  
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);  
            border: 1px solid \#e5e7eb;  
            transition: all 0.3s ease;  
        }

        .video-hero-card:hover {  
            transform: translateY(-2px);  
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);  
        }

        .video-thumbnail {  
            width: 80px;  
            height: 60px;  
            background: linear-gradient(135deg, \#ff6b6b 0%, \#ee5a24 100%);  
            border-radius: 12px;  
            display: flex;  
            align-items: center;  
            justify-content: center;  
            color: white;  
            font-size: 20px;  
            margin-right: 16px;  
            flex-shrink: 0;  
        }

        .scroll-hidden::-webkit-scrollbar { display: none; }  
        .scroll-hidden { \-ms-overflow-style: none; scrollbar-width: none; }

        .recommended-star-card {  
            background: white;  
            border-radius: 16px;   
            padding: 16px;   
            display: flex;  
            align-items: center;  
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);  
            border: 1px solid \#f3f4f6;   
            transition: all 0.3s ease;  
            width: 320px;   
        }  
        .recommended-star-card:hover {  
            transform: translateY(-2px);  
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);  
        }  
        .recommended-star-avatar {   
            width: 48px;   
            height: 48px;   
            border-radius: 12px;   
            display: flex;  
            align-items: center;  
            justify-content: center;  
            margin-right: 16px;   
            flex-shrink: 0;  
            color: white;  
        }  
         .recommended-star-avatar i {  
            font-size: 20px;   
        }

        .new-star-card {   
            background: white;  
            border-radius: 16px;  
            padding: 16px;  
            display: flex;  
            align-items: center;  
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);  
            border: 1px solid \#f3f4f6;  
            transition: all 0.3s ease;  
            width: 100%;   
        }  
        .new-star-card:hover {  
            transform: translateY(-2px);  
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);  
        }  
        .new-star-card-avatar {  
            width: 48px;   
            height: 48px;  
            border-radius: 12px;   
            display: flex;  
            align-items: center;  
            justify-content: center;  
            margin-right: 16px;   
            flex-shrink: 0;  
            overflow: hidden;   
        }  
        .new-star-card-avatar img {  
            width: 100%;  
            height: 100%;  
            object-fit: cover;  
        }

        .pickup-card {  
            background: white;  
            border-radius: 16px;  
            padding: 20px;  
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);  
            border: 1px solid \#f3f4f6;  
            transition: all 0.3s ease;  
        }  
        .pickup-card:hover {  
            transform: translateY(-2px);  
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);  
        }  
        .pickup-thumbnail {  
            width: 100%;  
            height: 150px;  
            border-radius: 12px;  
            background-color: \#e5e7eb;   
            margin-bottom: 12px;  
            display: flex;  
            align-items: center;  
            justify-content: center;  
            overflow: hidden;   
        }  
        .pickup-thumbnail img {  
            width: 100%;  
            height: 100%;  
            object-fit: cover;   
        }  
         .pickup-thumbnail i {   
            font-size: 48px;  
            color: \#9ca3af;  
        }

        .announcement-section {  
            margin-top: 3rem;   
            margin-bottom: 2rem;   
        }  
        .announcement-card {  
            background-color: white;  
            border-radius: 12px;   
            padding: 1.25rem;   
            box-shadow: 0 2px 8px rgba(0,0,0,0.07);  
            transition: box-shadow 0.3s ease;  
            display: flex;  
            align-items: flex-start;   
        }  
        .announcement-card:hover {  
            box-shadow: 0 4px 16px rgba(0,0,0,0.1);  
        }  
        .announcement-icon {  
            color: \#3b82f6;   
            font-size: 1.25rem;   
            margin-right: 0.75rem;   
            margin-top: 0.125rem;   
        }  
        .announcement-content h3 {  
            font-size: 1rem;   
            font-weight: 600;   
            color: \#1f2937;   
            margin-bottom: 0.25rem;  
        }  
        .announcement-content p {  
            font-size: 0.875rem;   
            color: \#4b5563;   
        }  
        .announcement-content a {  
            color: \#3b82f6;  
            text-decoration: none;  
        }  
        .announcement-content a:hover {  
            text-decoration: underline;  
        }

        .follow-button {   
            padding: 8px 16px;   
            border-radius: 12px;   
            font-size: 14px;   
            font-weight: 500;   
            transition: all 0.2s ease;  
            white-space: nowrap;  
        }  
        .follow-button.following {  
            background-color: \#6b7280;   
            color: white;  
        }  
        .follow-button.following:hover {  
            background-color: \#ef4444;   
        }

        /\* Ad Placeholder Styles \*/  
        .ad-placeholder-native {   
            border: 2px dashed \#cbd5e1;   
            background-color: \#f8fafc;   
        }  
        .ad-placeholder-native .recommended-star-avatar {  
             background: \#e2e8f0;   
        }  
        .ad-placeholder-native .recommended-star-avatar i {  
            color: \#64748b;   
        }  
        .ad-placeholder-banner {   
            min-height: 60px;   
            border: 2px dashed \#cbd5e1;  
            background-color: \#f1f5f9;   
            display: flex;  
            align-items: center;  
            justify-content: center;  
        }  
        .ad-placeholder-pickup {   
            border: 2px dashed \#fbbf24;   
            background-color: \#fffbeb;   
        }

    \</style\>  
\</head\>  
\<body class="bg-gray-50 pb-24"\>  
    \<header class="mobile-header fixed top-0 left-0 right-0 py-3 px-4 flex justify-between items-center h-14 z-50"\>  
        \<div class="flex items-center"\>  
            \<a href="\#" id="starlist-logo-link"\>  
                \<img src="https://placehold.co/160x40/ffffff/000000?text=STARLIST\&font=arial\&font-size=30\&font-weight=bold" alt="Starlist Logo" id="starlist-logo" class="h-10 w-auto"\>  
            \</a\>  
            \<h1 class="text-lg font-bold text-gray-900 hidden" id="header-title-text"\>\</h1\>  
        \</div\>  
        \<div class="flex items-center space-x-3"\>  
            \<button class="text-gray-600 hover:text-blue-600 p-2" title="通知" aria-label="通知を開く"\>  
                \<i class="far fa-bell text-lg"\>\</i\>  
            \</button\>  
            \<button class="text-gray-600 hover:text-blue-600 p-2" title="設定" aria-label="設定を開く"\>  
                \<i class="fas fa-cog text-lg"\>\</i\>  
            \</button\>  
        \</div\>  
    \</header\>

    \<main class="pt-16 pb-6"\>  
        \<section id="home-view" class="px-4"\>  
            \<div class="mb-8"\>  
                \<div class="flex justify-between items-center mb-6"\>  
                    \<h2 class="text-xl font-bold text-gray-900"\>最新のYoutube履歴\</h2\>  
                    \<button class="text-sm text-blue-600 hover:underline font-medium"\>すべて見る\</button\>  
                \</div\>  
                \<div class="youtube-history-hero"\>  
                    \<div class="flex items-center mb-4"\>  
                        \<div class="w-14 h-14 rounded-full bg-white bg-opacity-20 flex items-center justify-center mr-4"\>  
                            \<img src="https://placehold.co/56x56/FFFFFF/333333?text=Star" alt="スターアイコン" class="rounded-full object-cover" onerror="this.src='https://placehold.co/56x56/FFFFFF/333333?text=Error'; this.onerror=null;"\>  
                        \</div\>  
                        \<div\>  
                            \<h3 class="text-lg font-semibold text-white"\>田中 太郎 (スター名)\</h3\>  
                            \<p class="text-sm text-white opacity-80"\>10分前\</p\>  
                        \</div\>  
                    \</div\>  
                    \<p class="text-white mb-6 text-base leading-relaxed"\>今日見た動画のまとめです！面白い発見がたくさんありました。\</p\>  
                    \<div class="space-y-3"\>  
                        \<div class="video-hero-card"\>  
                            \<div class="flex items-center"\>  
                                \<div class="video-thumbnail"\>  
                                    \<i class="fab fa-youtube"\>\</i\>  
                                \</div\>  
                                \<div class="flex-grow"\>  
                                    \<h4 class="text-base font-semibold text-gray-900 mb-1"\>すごいAI技術の解説\</h4\>  
                                    \<p class="text-sm text-gray-600 mb-2"\>未来チャンネル • 18:20\</p\>  
                                    \<div class="flex items-center space-x-2"\>  
                                        \<span class="px-3 py-1 bg-red-100 text-red-700 text-xs rounded-full font-medium"\>YouTube\</span\>  
                                        \<span class="px-3 py-1 bg-blue-100 text-blue-700 text-xs rounded-full font-medium"\>テクノロジー\</span\>  
                                    \</div\>  
                                \</div\>  
                                \<button class="text-gray-400 hover:text-blue-600 p-2" title="共有" aria-label="動画を共有"\>  
                                    \<i class="fas fa-share text-lg"\>\</i\>  
                                \</button\>  
                            \</div\>  
                        \</div\>  
                    \</div\>  
                    \<div class="flex items-center justify-between mt-6 pt-4 border-t border-white border-opacity-20"\>  
                        \<div class="flex items-center space-x-6"\>  
                            \<button class="flex items-center space-x-2 text-white hover:text-red-200 transition-colors" title="いいね" aria-label="いいね"\>  
                                \<i class="far fa-heart text-lg"\>\</i\>  
                                \<span class="font-medium"\>35\</span\>  
                            \</button\>  
                            \<button class="flex items-center space-x-2 text-white hover:text-blue-200 transition-colors" title="コメント" aria-label="コメント"\>  
                                \<i class="far fa-comment text-lg"\>\</i\>  
                                \<span class="font-medium"\>12\</span\>  
                            \</button\>  
                        \</div\>  
                        \<button class="text-white hover:text-gray-200 transition-colors" title="シェア" aria-label="投稿をシェア"\>  
                            \<i class="fas fa-share text-lg"\>\</i\>  
                        \</button\>  
                    \</div\>  
                \</div\>  
            \</div\>

            \<div class="mb-8"\>  
                \<div class="flex justify-between items-center mb-6"\>  
                    \<h2 class="text-xl font-bold text-gray-900"\>あなたへのおすすめスター\</h2\>  
                    \<button class="text-sm text-blue-600 hover:underline font-medium"\>もっと見る\</button\>  
                \</div\>  
                \<div class="w-full flex space-x-4 overflow-x-auto scroll-hidden pb-4"\>  
                    \<div class="flex flex-col space-y-2 flex-shrink-0"\>  
                        \<div class="recommended-star-card" data-star-id="reco-star-1-grp1"\>  
                            \<div class="recommended-star-avatar bg-gradient-to-br from-blue-500 to-purple-600"\>  
                                \<i class="fas fa-user"\>\</i\>  
                            \</div\>  
                            \<div class="flex-grow"\>  
                                \<h4 class="text-base font-semibold text-gray-900"\>佐藤 次郎\</h4\>  
                                \<p class="text-sm text-gray-500"\>ゲーム実況 / VTuber\</p\>  
                            \</div\>  
                            \<button class="follow-button bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white"\>フォロー\</button\>  
                        \</div\>  
                          
                        \<div class="recommended-star-card ad-placeholder-native"\>  
                            \<div class="recommended-star-avatar"\>   
                                \<i class="fas fa-bullhorn"\>\</i\>   
                            \</div\>  
                            \<div class="flex-grow"\>  
                                \<h4 class="text-base font-semibold text-gray-900"\>おすすめサービス\</h4\>  
                                \<p class="text-sm text-gray-500"\>スポンサー提供\</p\>  
                            \</div\>  
                            \<a href="\#" class="text-xs text-blue-600 hover:underline font-medium px-3 py-1.5 rounded-lg border border-blue-600 whitespace-nowrap"\>詳しく見る\</a\>  
                        \</div\>

                        \<div class="recommended-star-card" data-star-id="reco-star-3-grp1"\>  
                           \<div class="recommended-star-avatar bg-gradient-to-br from-green-500 to-teal-500"\>  
                                \<i class="fas fa-user"\>\</i\>  
                            \</div\>  
                            \<div class="flex-grow"\>  
                                \<h4 class="text-base font-semibold text-gray-900"\>高橋 一郎\</h4\>  
                                \<p class="text-sm text-gray-500"\>教育系 / 解説\</p\>  
                            \</div\>  
                            \<button class="follow-button bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white"\>フォロー\</button\>  
                        \</div\>  
                    \</div\>

                    \<div class="flex flex-col space-y-2 flex-shrink-0"\>  
                        \<div class="recommended-star-card" data-star-id="reco-star-4-grp2"\>  
                            \<div class="recommended-star-avatar bg-gradient-to-br from-purple-500 to-indigo-500"\>  
                                \<i class="fas fa-user"\>\</i\>  
                            \</div\>  
                            \<div class="flex-grow"\>  
                                \<h4 class="text-base font-semibold text-gray-900"\>木村 あゆみ\</h4\>  
                                \<p class="text-sm text-gray-500"\>美容 / ファッション\</p\>  
                            \</div\>  
                            \<button class="follow-button bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700 text-white"\>フォロー\</button\>  
                        \</div\>  
                        \<div class="recommended-star-card" data-star-id="reco-star-5-grp2"\>  
                            \<div class="recommended-star-avatar bg-gradient-to-br from-orange-500 to-red-500"\>  
                                \<i class="fas fa-user"\>\</i\>  
                            \</div\>  
                            \<div class="flex-grow"\>  
                                \<h4 class="text-base font-semibold text-gray-900"\>山田 健司\</h4\>  
                                \<p class="text-sm text-gray-500"\>料理 / グルメ\</p\>  
                            \</div\>  
                            \<button class="follow-button bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white"\>フォロー\</button\>  
                        \</div\>  
                        \<div class="recommended-star-card" data-star-id="reco-star-6-grp2"\>  
                            \<div class="recommended-star-avatar bg-gradient-to-br from-cyan-500 to-blue-500"\>  
                                \<i class="fas fa-user"\>\</i\>  
                            \</div\>  
                            \<div class="flex-grow"\>  
                                \<h4 class="text-base font-semibold text-gray-900"\>中村 直樹\</h4\>  
                                \<p class="text-sm text-gray-500"\>テクノロジー / ガジェット\</p\>  
                            \</div\>  
                            \<button class="follow-button bg-gradient-to-r from-cyan-500 to-cyan-600 hover:from-cyan-600 hover:to-cyan-700 text-white"\>フォロー\</button\>  
                        \</div\>  
                    \</div\>  
                \</div\>  
            \</div\>

            \<div class="mb-8"\>  
                \<div class="flex justify-between items-center mb-6"\>  
                    \<h2 class="text-xl font-bold text-gray-900"\>新しく参加したスター\</h2\>  
                    \<button class="text-sm text-blue-600 hover:underline font-medium"\>もっと見る\</button\>  
                \</div\>  
                \<div class="grid grid-cols-1 sm:grid-cols-2 gap-4"\>  
                    \<div class="new-star-card" data-star-id="new-star-1"\>   
                        \<div class="new-star-card-avatar bg-gradient-to-br from-yellow-400 to-orange-500"\>  
                            \<img src="https://placehold.co/48x48/FFFFFF/333333?text=N1" alt="新着スター1" class="rounded-lg object-cover w-full h-full" onerror="this.src='https://placehold.co/48x48/FFFFFF/333333?text=Error'; this.onerror=null;"\>  
                        \</div\>  
                        \<div class="flex-grow"\>  
                            \<h4 class="text-base font-semibold text-gray-900"\>伊藤 さくら\</h4\>  
                            \<p class="text-sm text-gray-500"\>Vlog / ライフスタイル\</p\>  
                        \</div\>  
                        \<button class="follow-button bg-gradient-to-r from-yellow-500 to-yellow-600 hover:from-yellow-600 hover:to-yellow-700 text-white"\>フォロー\</button\>  
                    \</div\>  
                    \<div class="new-star-card" data-star-id="new-star-2"\>  
                        \<div class="new-star-card-avatar bg-gradient-to-br from-cyan-400 to-sky-500"\>  
                            \<img src="https://placehold.co/48x48/FFFFFF/333333?text=N2" alt="新着スター2" class="rounded-lg object-cover w-full h-full" onerror="this.src='https://placehold.co/48x48/FFFFFF/333333?text=Error'; this.onerror=null;"\>  
                        \</div\>  
                        \<div class="flex-grow"\>  
                            \<h4 class="text-base font-semibold text-gray-900"\>渡辺 健太\</h4\>  
                            \<p class="text-sm text-gray-500"\>音楽 / DTM\</p\>  
                        \</div\>  
                        \<button class="follow-button bg-gradient-to-r from-cyan-500 to-cyan-600 hover:from-cyan-600 hover:to-cyan-700 text-white"\>フォロー\</button\>  
                    \</div\>  
                \</div\>  
            \</div\>  
              
            \<div class="my-8 p-4 rounded-lg text-center text-gray-600 ad-placeholder-banner"\>  
                \<i class="fas fa-ad mr-2"\>\</i\>広告スペース (例: 横長バナー)  
            \</div\>

            \<div class="mb-8"\>  
                \<h2 class="text-xl font-bold text-gray-900 mb-6"\>今日のピックアップ\</h2\>  
                \<div class="grid grid-cols-1 md:grid-cols-2 gap-6"\>  
                    \<div class="pickup-card"\>  
                        \<div class="pickup-thumbnail"\>  
                            \<img src="https://placehold.co/600x400/cccccc/969696?text=注目動画1" alt="注目動画のサムネイル1" onerror="this.src='https://placehold.co/600x400/cccccc/969696?text=Error'; this.onerror=null;"\>  
                        \</div\>  
                        \<h3 class="text-lg font-semibold text-gray-900 mb-2"\>驚きのDIYプロジェクト！部屋が劇場に変身\</h3\>  
                        \<p class="text-sm text-gray-600 mb-3"\>投稿者: \<a href="\#" class="text-blue-600 hover:underline"\>クリエイティブ太郎\</a\>\</p\>  
                        \<p class="text-sm text-gray-700 leading-relaxed mb-4"\>この動画では、普通の部屋を本格的なホームシアターに変える過程を紹介しています。週末に挑戦できるかも？\</p\>  
                        \<div class="flex items-center space-x-2"\>  
                            \<span class="px-3 py-1 bg-indigo-100 text-indigo-700 text-xs rounded-full font-medium"\>DIY\</span\>  
                            \<span class="px-3 py-1 bg-pink-100 text-pink-700 text-xs rounded-full font-medium"\>ライフハック\</span\>  
                        \</div\>  
                    \</div\>  
                    \<div class="pickup-card ad-placeholder-pickup"\>  
                        \<div class="pickup-thumbnail bg-amber-100 flex items-center justify-center"\>  
                             \<span class="text-amber-600 text-2xl font-semibold"\>広告\</span\>  
                        \</div\>  
                        \<h3 class="text-lg font-semibold text-gray-900 mb-2"\>限定オファーをお見逃しなく！\</h3\>  
                        \<p class="text-sm text-gray-600 mb-3"\>提供: スポンサーA\</p\>  
                        \<p class="text-sm text-gray-700 leading-relaxed mb-4"\>今だけの特別なキャンペーン情報です。クリックして詳細を確認してください。\</p\>  
                        \<a href="\#" class="inline-block bg-amber-500 hover:bg-amber-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"\>詳細はこちら\</a\>  
                    \</div\>  
                \</div\>  
            \</div\>

            \<div class="announcement-section"\>  
                 \<h2 class="text-xl font-bold text-gray-900 mb-6"\>Starlistからのお知らせ\</h2\>  
                 \<div class="space-y-2"\>  
                     \<div class="announcement-card"\>  
                         \<i class="fas fa-bullhorn announcement-icon"\>\</i\>  
                         \<div class="announcement-content"\>  
                             \<h3\>\<a href="\#"\>新しいフィルター機能が追加されました！\</a\>\</h3\>  
                             \<p\>より詳細な検索が可能になり、お目当てのスターやコンテンツが見つけやすくなりました。(5/20)\</p\>  
                         \</div\>  
                     \</div\>  
                     \<div class="announcement-card"\>  
                        \<i class="fas fa-tools announcement-icon"\>\</i\>  
                        \<div class="announcement-content"\>  
                             \<h3\>\<a href="\#"\>サーバーメンテナンスのお知らせ\</a\>\</h3\>  
                             \<p\>5月28日深夜2時～4時の間、サービス向上のためのメンテナンスを実施します。ご協力をお願いいたします。\</p\>  
                         \</div\>  
                     \</div\>  
                      \<div class="announcement-card"\>  
                        \<i class="fas fa-star announcement-icon"\>\</i\>  
                        \<div class="announcement-content"\>  
                             \<h3\>\<a href="\#"\>スター紹介キャンペーン開始！\</a\>\</h3\>  
                             \<p\>お友達のクリエイターをStarlistに紹介すると、特典がもらえるキャンペーンがスタートしました！\</p\>  
                         \</div\>  
                     \</div\>  
                 \</div\>  
            \</div\>  
        \</section\>

        \<section id="input-view" class="px-4 hidden"\>  
            \</section\>  
        \<section id="search-view" class="px-4 hidden"\>  
            \</section\>  
        \<section id="favorites-view" class="px-4 hidden"\>  
            \</section\>  
        \<section id="profile-view" class="px-4 hidden"\>  
            \</section\>  
    \</main\>

    \<nav class="bottom-nav fixed bottom-0 left-0 right-0 py-2 px-4"\>  
        \</nav\>

    \<script type="module"\>  
        // Firebase SDKs  
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";  
        import { getAuth, signInAnonymously, signInWithCustomToken, onAuthStateChanged, setPersistence, browserLocalPersistence } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";  
        import { getFirestore, doc, getDoc, setDoc, deleteDoc, enableIndexedDbPersistence, setLogLevel } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

        const appId \= typeof \_\_app\_id \!== 'undefined' ? \_\_app\_id : 'starlist-dev-app';   
        const firebaseConfig \= typeof \_\_firebase\_config \!== 'undefined' ? JSON.parse(\_\_firebase\_config) : {  
            apiKey: "YOUR\_API\_KEY",   
            authDomain: "YOUR\_AUTH\_DOMAIN",  
            projectId: "YOUR\_PROJECT\_ID",  
            storageBucket: "YOUR\_STORAGE\_BUCKET",  
            messagingSenderId: "YOUR\_MESSAGING\_SENDER\_ID",  
            appId: "YOUR\_APP\_ID"  
        };  
        const initialAuthToken \= typeof \_\_initial\_auth\_token \!== 'undefined' ? \_\_initial\_auth\_token : null;

        let app;  
        let auth;  
        let db;  
        let currentUserId \= null;  
        let isAuthReady \= false;

        try {  
            app \= initializeApp(firebaseConfig);  
            auth \= getAuth(app);  
            db \= getFirestore(app);  
            setLogLevel('debug'); 

            await enableIndexedDbPersistence(db).catch((err) \=\> {  
                if (err.code \== 'failed-precondition') {  
                    console.warn("Firestore persistence failed: Multiple tabs open or other issues.");  
                } else if (err.code \== 'unimplemented') {  
                    console.warn("Firestore persistence failed: Browser doesn't support it.");  
                }  
            });  
            await setPersistence(auth, browserLocalPersistence);

        } catch (error) {  
            console.error("Firebase initialization error:", error);  
        }  
          
        function updateFollowButtonUI(button, isFollowing) {  
            const starCard \= button.closest('.recommended-star-card, .new-star-card');  
            let originalClasses \= \[\];

            if (starCard && \!button.dataset.originalClasses) {  
                 const btnClasses \= Array.from(button.classList).filter(cls \=\> cls.startsWith('from-') || cls.startsWith('to-') || cls.startsWith('bg-gradient-to-') || cls.startsWith('hover:from-') || cls.startsWith('hover:to-'));  
                 button.dataset.originalClasses \= btnClasses.join(' ');  
            }  
            originalClasses \= button.dataset.originalClasses ? button.dataset.originalClasses.split(' ') : \[\];

            if (isFollowing) {  
                button.textContent \= 'フォロー中';  
                button.classList.add('following');  
                button.classList.forEach(cls \=\> {  
                    if (cls.startsWith('from-') || cls.startsWith('to-') || cls.startsWith('bg-gradient-to-') || cls.startsWith('hover:from-') || cls.startsWith('hover:to-')) {  
                        button.classList.remove(cls);  
                    }  
                });  
                button.style.background \= '\#6b7280';   
            } else {  
                button.textContent \= 'フォロー';  
                button.classList.remove('following');  
                button.style.background \= '';   
                if (originalClasses.length \> 0\) {  
                    originalClasses.forEach(cls \=\> button.classList.add(cls));  
                } else {  
                    button.classList.add('bg-gradient-to-r', 'from-blue-500', 'to-blue-600', 'hover:from-blue-600', 'hover:to-blue-700');  
                }  
            }  
        }  
        async function checkFollowStatus(starId, buttonElement) {  
            if (\!isAuthReady || \!currentUserId || \!db) return;  
            if (buttonElement.closest('.ad-placeholder-native')) return;  
            try {  
                const followDocRef \= doc(db, \`artifacts/${appId}/users/${currentUserId}/followedStars\`, starId);  
                const docSnap \= await getDoc(followDocRef);  
                updateFollowButtonUI(buttonElement, docSnap.exists());  
            } catch (error) {  
                console.error("Error checking follow status for " \+ starId \+ ":", error);  
            }  
        }  
        async function toggleFollow(starId, buttonElement) {  
            if (\!isAuthReady || \!currentUserId || \!db) { return; }  
            if (buttonElement.closest('.ad-placeholder-native')) return;  
            const followDocRef \= doc(db, \`artifacts/${appId}/users/${currentUserId}/followedStars\`, starId);  
            try {  
                const docSnap \= await getDoc(followDocRef);  
                if (docSnap.exists()) {  
                    await deleteDoc(followDocRef);  
                    updateFollowButtonUI(buttonElement, false);  
                } else {  
                    await setDoc(followDocRef, { followedAt: new Date() });  
                    updateFollowButtonUI(buttonElement, true);  
                }  
            } catch (error) {  
                console.error("Error toggling follow for " \+ starId \+ ":", error);  
                buttonElement.textContent \= 'エラー';  
                setTimeout(() \=\> checkFollowStatus(starId, buttonElement), 2000);  
            }  
        }  
        function initializeFollowButtons() {  
            if (\!isAuthReady) return;  
            const followButtons \= document.querySelectorAll('.follow-button');  
            followButtons.forEach(button \=\> {  
                const starCard \= button.closest('.recommended-star-card\[data-star-id\], .new-star-card\[data-star-id\]');  
                if (starCard && \!starCard.classList.contains('ad-placeholder-native')) {  
                    const starId \= starCard.dataset.starId;  
                    if (starId) {  
                        if (\!button.dataset.originalClasses) {   
                            const btnClasses \= Array.from(button.classList).filter(cls \=\> cls.startsWith('from-') || cls.startsWith('to-') || cls.startsWith('bg-gradient-to-') || cls.startsWith('hover:from-') || cls.startsWith('hover:to-'));  
                            button.dataset.originalClasses \= btnClasses.join(' ');  
                        }  
                        checkFollowStatus(starId, button);   
                        button.removeEventListener('click', button.\_clickHandler);   
                        button.\_clickHandler \= () \=\> toggleFollow(starId, button);   
                        button.addEventListener('click', button.\_clickHandler);  
                    }  
                }  
            });  
        }  
        if (auth) {  
            onAuthStateChanged(auth, async (user) \=\> {  
                if (user) {  
                    currentUserId \= user.uid;  
                } else {  
                    try {  
                        if (initialAuthToken) {  
                            await signInWithCustomToken(auth, initialAuthToken);  
                        } else {  
                            await signInAnonymously(auth);  
                        }  
                    } catch (error) {  
                        console.error("Error during sign-in:", error);  
                        currentUserId \= null;  
                    }  
                }  
                isAuthReady \= true;   
                initializeFollowButtons();   
            });  
        }

        document.addEventListener('DOMContentLoaded', function() {  
            const navItems \= document.querySelectorAll('.nav-item');  
            const sections \= document.querySelectorAll('main \> section');  
            const mobileHeader \= document.querySelector('.mobile-header');  
            const headerLogoLink \= document.getElementById('starlist-logo-link');   
            const headerLogoImg \= document.getElementById('starlist-logo');      
            const headerTitleTextEl \= document.getElementById('header-title-text');

            let lastScrollY \= window.scrollY;  
            let isScrolling \= false;

            function handleScroll() {  
                 if (\!isScrolling) {  
                    window.requestAnimationFrame(() \=\> {  
                        const currentScrollY \= window.scrollY;  
                        if (currentScrollY \> lastScrollY && currentScrollY \> 100\) {  
                            mobileHeader.classList.add('hidden');  
                        } else if (currentScrollY \< lastScrollY) {  
                            mobileHeader.classList.remove('hidden');  
                        }  
                        lastScrollY \= currentScrollY;  
                        isScrolling \= false;  
                    });  
                }  
                isScrolling \= true;  
            }  
            window.addEventListener('scroll', handleScroll, { passive: true });

            const titles \= {  
                'home-view': 'ホーム',   
                'search-view': '検索',  
                'input-view': 'データ取り込み',  
                'favorites-view': 'お気に入り',  
                'profile-view': 'プロフィール'  
            };

            function updateHeaderDisplay(viewId) {  
                if (viewId \=== 'home-view') {  
                    if (headerLogoLink) headerLogoLink.classList.remove('hidden');   
                    if (headerTitleTextEl) headerTitleTextEl.classList.add('hidden');  
                } else {  
                    if (headerLogoLink) headerLogoLink.classList.add('hidden');   
                    if (headerTitleTextEl) {  
                        headerTitleTextEl.classList.remove('hidden');  
                        headerTitleTextEl.textContent \= titles\[viewId\] || 'Starlist';   
                    }  
                }  
            }  
              
            let currentActiveView \= 'home-view';   
            sections.forEach(section \=\> {  
                if (\!section.classList.contains('hidden')) {  
                    currentActiveView \= section.id;  
                }  
            });  
            updateHeaderDisplay(currentActiveView);

            if (headerLogoLink) {  
                headerLogoLink.addEventListener('click', function(event) {  
                    event.preventDefault();   
                    const homeNavItem \= document.querySelector('.nav-item\[data-view="home-view"\]');  
                    if (homeNavItem) {  
                        homeNavItem.click();   
                    }  
                });  
            }

            navItems.forEach(item \=\> {  
                item.addEventListener('click', function() {  
                    const targetView \= this.getAttribute('data-view');  
                      
                    navItems.forEach(nav \=\> nav.classList.remove('active'));  
                    this.classList.add('active');  
                      
                    sections.forEach(section \=\> section.classList.add('hidden'));  
                    const targetSection \= document.getElementById(targetView);  
                    if (targetSection) {  
                        targetSection.classList.remove('hidden');  
                    }  
                      
                    updateHeaderDisplay(targetView);   
                      
                    mobileHeader.classList.remove('hidden');  
                    window.scrollTo({ top: 0, behavior: 'smooth' });

                    if (targetView \=== 'home-view' && isAuthReady) {  
                        initializeFollowButtons();   
                    }  
                });  
            });

            const contentTypeCards \= document.querySelectorAll('.content-type-enhanced');  
            const displays \= {  
                'products': document.getElementById('products-display'),  
                'videos': document.getElementById('videos-display'),  
                'music': document.getElementById('music-display')  
            };  
            contentTypeCards.forEach(card \=\> {  
                card.addEventListener('click', function() {  
                    const type \= this.getAttribute('data-type');  
                    contentTypeCards.forEach(c \=\> c.classList.remove('active'));  
                    this.classList.add('active');  
                    Object.values(displays).forEach(display \=\> {  
                        if (display) display.classList.add('hidden');  
                    });  
                    if (displays\[type\]) {  
                        displays\[type\].classList.remove('hidden');  
                    }  
                });  
            });  
              
            if (document.getElementById('home-view') && \!document.getElementById('home-view').classList.contains('hidden') && isAuthReady) {  
                 initializeFollowButtons();  
            }  
        });  
    \</script\>  
\</body\>  
\</html\>

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
