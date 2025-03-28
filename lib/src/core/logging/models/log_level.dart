enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final dynamic data;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return "[${timestamp.toIso8601String()}] ${level.name.toUpperCase()}: $message${data != null ? "
Data: $data" : ""}";
  }
}

abstract class Logger {
  void log(LogLevel level, String message, {dynamic data});
  void debug(String message, {dynamic data}) => log(LogLevel.debug, message, data: data);
  void info(String message, {dynamic data}) => log(LogLevel.info, message, data: data);
  void warning(String message, {dynamic data}) => log(LogLevel.warning, message, data: data);
  void error(String message, {dynamic data}) => log(LogLevel.error, message, data: data);
}
