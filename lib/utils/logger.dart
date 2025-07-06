import 'dart:developer' as developer;

class Logger {
  static void log(String message, {String? tag}) {
    if (tag != null) {
      developer.log(message, name: tag);
    } else {
      developer.log(message);
    }
  }
  
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (tag != null) {
      developer.log(message, name: tag, error: error, stackTrace: stackTrace);
    } else {
      developer.log(message, error: error, stackTrace: stackTrace);
    }
  }
} 