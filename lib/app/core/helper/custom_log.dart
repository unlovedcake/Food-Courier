import 'package:flutter/material.dart';

enum LogLevel {
  info('INFO  ℹ️ℹ️ℹ️ \n', TextColor.brightCyan),
  success('SUCCESS ✅✅✅ \n', TextColor.green),
  warn('WARNING ⚠️⚠️⚠️ \n', TextColor.yellow),
  error('ERROR ❌❌❌ \n', TextColor.red),
  debug('DEBUG 🐞🐞🐞 \n', TextColor.magenta);

  const LogLevel(this.label, this.defaultColor);
  final String label;
  final TextColor defaultColor;
}

enum TextColor {
  black('\x1B[30m'),
  red('\x1B[31m'),
  green('\x1B[32m'),
  yellow('\x1B[33m'),
  blue('\x1B[34m'),
  magenta('\x1B[35m'),
  cyan('\x1B[36m'),
  white('\x1B[37m'),
  brightBlack('\x1B[90m'),
  brightRed('\x1B[91m'),
  brightGreen('\x1B[92m'),
  brightYellow('\x1B[93m'),
  brightBlue('\x1B[94m'),
  brightMagenta('\x1B[95m'),
  brightCyan('\x1B[96m'),
  brightWhite('\x1B[97m'),
  reset('\x1B[0m');

  const TextColor(this.ansi);
  final String ansi;
}

class Print {
  Print._();

  static void success(String message, {TextColor? textColor}) =>
      _log(message, level: LogLevel.success, textColor: textColor);

  static void error(String message, {TextColor? textColor}) =>
      _log(message, level: LogLevel.error, textColor: textColor);

  static void warn(String message, {TextColor? textColor}) =>
      _log(message, level: LogLevel.warn, textColor: textColor);

  static void info(String message, {TextColor? textColor}) =>
      _log(message, level: LogLevel.info, textColor: textColor);

  static void debug(String message, {TextColor? textColor}) =>
      _log(message, level: LogLevel.debug, textColor: textColor);

  static String _getCallerInfo(StackTrace stackTrace, String colorCode) {
    final List<String> lines = stackTrace.toString().split('\n');

    String white = '\x1B[37m';

    for (final line in lines) {
      if (line.contains('package:') &&
          !line.contains('custom_log.dart') && // <-- your Print file
          !line.contains('Print.') && // <-- skip Print.info, etc.
          !line.contains('_log')) {
        final RegExpMatch? match =
            RegExp(r'#\d+\s+(.+)\s+\((.+):(\d+):\d+\)').firstMatch(line);
        if (match != null) {
          final String? method = match.group(1);
          final String? file = match.group(2);
          final String? lineNum = match.group(3);
          return '🔍 $colorCode$file:Code$lineNum in $white$method';
        }
      }
    }

    return '';
  }

  static void _log(
    String message, {
    required LogLevel level,
    TextColor? textColor,
  }) {
    const int maxLineLength = 100;

    final String colorCode = (textColor ?? level.defaultColor).ansi;
    final String reset = TextColor.reset.ansi;

    final now = DateTime.now();
    final timestamp = '[${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}]';

    // Parse caller info
    final StackTrace stackTrace = StackTrace.current;
    final String callerInfo = _getCallerInfo(stackTrace, colorCode);

    // Wrap a line at maxLineLength
    List<String> wrapLine(String line, int maxLen) {
      List<String> wrapped = [];
      for (int i = 0; i < line.length; i += maxLen) {
        wrapped.add(line.substring(i, (i + maxLen).clamp(0, line.length)));
      }
      return wrapped;
    }

    // Split on new lines and wrap each line
    final List<String> lines = message.split('\n');
    final List<String> wrappedLines =
        lines.expand((line) => wrapLine(line, maxLineLength)).toList();

    final int maxWidth =
        wrappedLines.map((l) => l.length).reduce((a, b) => a > b ? a : b);

    final String horizontal = '-' * (maxWidth + 2);
    final String top = '$colorCode┌$horizontal┐';
    final String bottom = '$colorCode└$horizontal┘$reset';

    final String boxedLines = wrappedLines
        .map((l) => '$colorCode│ ${l.padRight(maxWidth)} │')
        .join('\n');

    final String output =
        '$colorCode$timestamp ${level.label} $callerInfo\n$top\n$boxedLines\n$bottom$reset';

    // Safely print output in chunks (Flutter has a limit per log line)
    const chunkSize = 800;
    for (int i = 0; i < output.length; i += chunkSize) {
      final String chunk =
          output.substring(i, (i + chunkSize).clamp(0, output.length));
      debugPrint(chunk);
    }
  }
}

// enum LogLevel {
//   info('ℹ️ INFO', 'white'),
//   success('✅ SUCCESS', 'green'),
//   warn('⚠️ WARNING', 'yellow'),
//   error('🛑 ERROR', 'red'),
//   debug('🐞 DEBUG', 'magenta');

//   const LogLevel(this.label, this.color); // ✅ Constructor comes first

//   final String label;
//   final String color;
// }

// class Print {
//   Print._();
//   static void success(String message, {String? textColor}) =>
//       _log('✅ $message', level: LogLevel.success, textColor: textColor);
//   static void error(String message, {String? textColor}) =>
//       _log('🛑 $message', level: LogLevel.error, textColor: textColor);
//   static void warn(String message, {String? textColor}) =>
//       _log('⚠️ $message', level: LogLevel.warn, textColor: textColor);
//   static void info(String message, {String? textColor}) =>
//       _log('ℹ️ $message', level: LogLevel.info, textColor: textColor);
//   static void debug(String message, {String? textColor}) =>
//       _log('🐞 $message', level: LogLevel.debug, textColor: textColor);

//   static void _log(
//     String message, {
//     required LogLevel level,
//     String? textColor,
//   }) {
//     //ANSI color codes
//     final colors = {
//       'black': '\x1B[30m',
//       'red': '\x1B[31m',
//       'green': '\x1B[32m',
//       'yellow': '\x1B[33m',
//       'blue': '\x1B[34m',
//       'magenta': '\x1B[35m',
//       'cyan': '\x1B[36m',
//       'white': '\x1B[37m',
//       'reset': '\x1B[0m',
//     };

//     final String colorKey = textColor ?? level.color;
//     final String colorCode = colors[colorKey] ?? colors['white']!;
//     final String reset = colors['reset']!;

//     final now = DateTime.now();
//     final timestamp = '[${now.hour.toString().padLeft(2, '0')}:'
//         '${now.minute.toString().padLeft(2, '0')}:'
//         '${now.second.toString().padLeft(2, '0')}]';

//     final List<String> lines = message.split('\n');
//     final int maxWidth =
//         lines.map((l) => l.length).reduce((a, b) => a > b ? a : b);
//     final String horizontal = '─' * (maxWidth + 2);
//     final top = '$colorCode┌$horizontal┐';
//     final bottom = '$colorCode└$colorCode$horizontal┘$reset';
//     final String boxedLines =
//         lines.map((l) => '│ ${l.padRight(maxWidth)} │').join('\n');

//     debugPrint(
//       '$colorCode$timestamp ${level.label}\n$top\n$colorCode$boxedLines\n$bottom$reset',
//     );
//   }
// }

// Emoji	Meaning	Example
// ✅	Success/Loaded	debugPrint('✅ Messages loaded for $chatId');
// ⚠️	Warning	debugPrint('⚠️ Something might be wrong');
// 🛑	Error/Stop	debugPrint('🛑 Failed to load messages');
// 📭	No more content	debugPrint('📭 No more messages to load');
// 🔄	Loading	debugPrint('🔄 Fetching messages...');
// 💬	Chat related	debugPrint('💬 New chat started: $chatId');
