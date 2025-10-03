module.exports = {
  ui: {
    port: 3001
  },
  files: [
    // FlutterのビルドされたJSファイルのみを監視（頻繁な更新を防ぐ）
    "build/web/main.dart.js",
  ],
  watchEvents: ["change"],
  watchOptions: {
    ignoreInitial: true,
    awaitWriteFinish: {
      stabilityThreshold: 2000  // ビルド完了を待つ
    },
    usePolling: true,
    interval: 500,  // ポーリング間隔を長めに
    ignored: [
      '**/.*',
      '**/.dart_tool/**',
      '**/build/web/assets/**',
      '**/build/web/canvaskit/**',
      '**/build/web/flutter_service_worker.js',
      '**/build/web/version.json',
    ]
  },
  proxy: "http://localhost:8080",
  port: 3000,
  open: false,
  reloadOnRestart: false,  // 自動リスタート時のリロードを無効化
  reloadDelay: 1000,  // リロード前のディレイ
  reloadDebounce: 2000,  // 連続リロードを防ぐ
  notify: {
    styles: {
      top: 'auto',
      bottom: '10px',
      right: '10px',
      left: 'auto',
      borderRadius: '8px',
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      color: 'white',
      padding: '12px 16px',
      fontSize: '14px',
      fontWeight: '600'
    }
  },
  ghostMode: false,
  logLevel: "info"
};

