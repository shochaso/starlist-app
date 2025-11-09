import 'package:flutter/foundation.dart';

typedef LogSink = void Function(String message);

class LogAdapter {
  LogAdapter({String tag = 'ops', LogSink? sink}) : _tag = tag, _sink = sink ?? debugPrint;

  final String _tag;
  final LogSink _sink;

  void info(String category, String message) => _sink('[$_tag][$category] $message');
  void warn(String category, String message) => _sink('[$_tag][$category][warn] $message');
  void error(String category, String message) => _sink('[$_tag][$category][error] $message');
}
