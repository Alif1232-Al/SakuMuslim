import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static String _logDirectory = '';
  static bool _initialized = false;

  // ═══════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════

  static Future<void> init() async {
    if (_initialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _logDirectory = '${directory.path}/logs';

      // Create logs directory if not exists
      final logDir = Directory(_logDirectory);
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _initialized = true;
      info('Logger initialized successfully');
    } catch (e) {
      // If path_provider fails, continue without file logging
      _initialized = true;
      if (kDebugMode) {
        print('[WARN] Logger file system not available: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  // LOGGING METHODS
  // ═══════════════════════════════════════════════════════

  static void info(String message) {
    _log('INFO', message);
  }

  static void debug(String message) {
    if (kDebugMode) {
      _log('DEBUG', message);
    }
  }

  static void warning(String message) {
    _log('WARNING', message);
  }

  static void error(String message, [dynamic error, StackTrace? stack]) {
    _log('ERROR', message, error, stack);
  }

  static void critical(String message, [dynamic error, StackTrace? stack]) {
    _log('CRITICAL', message, error, stack);
  }

  // ═══════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ═══════════════════════════════════════════════════════

  static void _log(
    String level,
    String message, [
    dynamic error,
    StackTrace? stack,
  ]) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = _formatLogEntry(timestamp, level, message, error, stack);

    // Console output (debug mode only)
    if (kDebugMode) {
      _printToConsole(level, message, error, stack);
    }

    // File output (both debug and release)
    _writeToFile(logEntry);
  }

  static void _printToConsole(
    String level,
    String message,
    dynamic error,
    StackTrace? stack,
  ) {
    final prefix = _getLevelPrefix(level);
    print('$prefix $message');

    if (error != null) {
      print('  └─ Error: $error');
    }
    if (stack != null) {
      print('  └─ Stack: ${stack.toString().split('\n').first}');
    }
  }

  static String _formatLogEntry(
    String timestamp,
    String level,
    String message,
    dynamic error,
    StackTrace? stack,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] [$level] $message');

    if (error != null) {
      buffer.writeln('  Error: $error');
    }
    if (stack != null) {
      buffer.writeln('  Stack: $stack');
    }

    return buffer.toString();
  }

  static String _getLevelPrefix(String level) {
    switch (level) {
      case 'INFO':
        return '\x1B[32m[INFO]\x1B[0m';  // Green
      case 'DEBUG':
        return '\x1B[36m[DEBUG]\x1B[0m'; // Cyan
      case 'WARNING':
        return '\x1B[33m[WARN]\x1B[0m';  // Yellow
      case 'ERROR':
        return '\x1B[31m[ERROR]\x1B[0m'; // Red
      case 'CRITICAL':
        return '\x1B[35m[CRIT]\x1B[0m';  // Magenta
      default:
        return '[LOG]';
    }
  }

  static Future<void> _writeToFile(String logEntry) async {
    if (!_initialized || _logDirectory.isEmpty) return;

    try {
      final fileName = _getLogFileName();
      final file = File('$_logDirectory/$fileName');

      // Append to log file
      await file.writeAsString(
        logEntry,
        mode: FileMode.append,
        flush: true,
      );

      // Clean old logs (keep last 7 days)
      await _cleanOldLogs();
    } catch (e) {
      if (kDebugMode) {
        print('[LOG ERROR] Failed to write log: $e');
      }
    }
  }

  static String _getLogFileName() {
    final now = DateTime.now();
    return 'sakumuslim_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}.log';
  }

  static Future<void> _cleanOldLogs() async {
    try {
      final logDir = Directory(_logDirectory);
      if (!await logDir.exists()) return;

      final now = DateTime.now();
      final files = await logDir.list().toList();

      for (final file in files) {
        if (file is File && file.path.endsWith('.log')) {
          final fileStat = await file.stat();
          final fileAge = now.difference(fileStat.modified);

          // Delete logs older than 7 days
          if (fileAge.inDays > 7) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LOG ERROR] Failed to clean old logs: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════

  static Future<String> getLogDirectory() async {
    if (!_initialized) await init();
    return _logDirectory;
  }

  static Future<List<File>> getLogFiles() async {
    if (!_initialized) await init();

    try {
      final logDir = Directory(_logDirectory);
      if (!await logDir.exists()) return [];

      final files = await logDir.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.log'))
          .map((file) => file as File)
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path)); // Newest first
    } catch (e) {
      return [];
    }
  }

  static Future<String> getLogContent(File logFile) async {
    try {
      return await logFile.readAsString();
    } catch (e) {
      return 'Error reading log file: $e';
    }
  }
}
