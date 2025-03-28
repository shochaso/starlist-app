import "dart:developer" as developer;
import "package:path_provider/path_provider.dart";
import "dart:io";

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  File? _logFile;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory("${appDir.path}/logs");
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    _logFile = File("${logDir.path}/app.log");
    _isInitialized = true;
  }

  Future<void> log(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) async {
    await initialize();

    final timestamp = DateTime.now().toIso8601String();
    final logMessage = "[$timestamp] ${level.name.toUpperCase()}: $message";

    // コンソールに出力
    switch (level) {
      case LogLevel.debug:
        developer.log(message);
        break;
      case LogLevel.info:
        developer.log(message, name: "INFO");
        break;
      case LogLevel.warning:
        developer.log(message, name: "WARNING");
        break;
      case LogLevel.error:
        developer.log(message, name: "ERROR", error: error, stackTrace: stackTrace);
        break;
    }

    // ファイルに出力
    if (_logFile != null) {
      await _logFile!.writeAsString("$logMessage\n", mode: FileMode.append);
      if (error != null) {
        await _logFile!.writeAsString("Error: $error\n", mode: FileMode.append);
      }
      if (stackTrace != null) {
        await _logFile!.writeAsString("StackTrace: $stackTrace\n", mode: FileMode.append);
      }
    }
  }

  Future<void> debug(String message) => log(LogLevel.debug, message);
  Future<void> info(String message) => log(LogLevel.info, message);
  Future<void> warning(String message) => log(LogLevel.warning, message);
  Future<void> error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
      await _logFile!.create();
    }
  }
}
