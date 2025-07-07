import 'package:flutter/material.dart';

/// 遅延ローディング管理クラス
/// UI/UXを損なわずに重い機能を段階的に読み込み
class LazyLoadingManager {
  static final LazyLoadingManager _instance = LazyLoadingManager._internal();
  factory LazyLoadingManager() => _instance;
  LazyLoadingManager._internal();

  final Map<String, bool> _loadedModules = {};
  final Map<String, Future<dynamic>> _loadingModules = {};

  /// モジュールが読み込み済みかチェック
  bool isLoaded(String moduleId) => _loadedModules[moduleId] ?? false;

  /// 重い機能の遅延ロード
  Future<T> loadModule<T>(
    String moduleId,
    Future<T> Function() loader, {
    Widget Function()? placeholder,
  }) async {
    // 既に読み込み済み
    if (_loadedModules[moduleId] == true) {
      return await _loadingModules[moduleId] as T;
    }

    // 読み込み中でない場合は開始
    if (!_loadingModules.containsKey(moduleId)) {
      _loadingModules[moduleId] = _loadModuleInternal(moduleId, loader);
    }

    return await _loadingModules[moduleId] as T;
  }

  Future<T> _loadModuleInternal<T>(
    String moduleId,
    Future<T> Function() loader,
  ) async {
    try {
      final result = await loader();
      _loadedModules[moduleId] = true;
      return result;
    } catch (e) {
      _loadingModules.remove(moduleId);
      rethrow;
    }
  }

  /// メモリクリア（低メモリ時）
  void clearModule(String moduleId) {
    _loadedModules.remove(moduleId);
    _loadingModules.remove(moduleId);
  }
}

/// 遅延ローディング対応Widget
class LazyWidget extends StatefulWidget {
  final String moduleId;
  final Future<Widget> Function() builder;
  final Widget placeholder;

  const LazyWidget({
    super.key,
    required this.moduleId,
    required this.builder,
    required this.placeholder,
  });

  @override
  State<LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<LazyWidget> {
  Widget? _loadedWidget;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  Future<void> _loadWidget() async {
    if (LazyLoadingManager().isLoaded(widget.moduleId)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final widget = await LazyLoadingManager().loadModule(
        this.widget.moduleId,
        this.widget.builder,
      );
      
      if (mounted) {
        setState(() {
          _loadedWidget = widget;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadedWidget != null) {
      return _loadedWidget!;
    }

    return widget.placeholder;
  }
} 