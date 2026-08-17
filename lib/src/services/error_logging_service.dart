import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Web replacement for FirebaseCrashlytics (which has no web implementation).
/// Logs errors as Firebase Analytics events instead. Same call shape as
/// FirebaseCrashlytics.instance.recordError so call sites stay unchanged.
///
/// Analytics event string parameters are capped at 100 characters, so
/// exception/stack trace text is truncated — this is a lighter-weight
/// substitute, not a full crash-reporting tool.
class ErrorLoggingService {
  ErrorLoggingService._();
  static final ErrorLoggingService instance = ErrorLoggingService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    List<String>? information,
    bool printDetails = false,
    bool fatal = false,
  }) async {
    if (printDetails) {
      debugPrint(
        '[ErrorLoggingService]${fatal ? ' [FATAL]' : ''} $reason\n'
        '$exception\n$stackTrace\n${(information ?? []).join(', ')}',
      );
    }
    await _analytics.logEvent(
      name: fatal ? 'app_fatal_error' : 'app_error',
      parameters: {
        'reason': _truncate(reason ?? ''),
        'error': _truncate(exception.toString()),
        'info': _truncate((information ?? []).join(' | ')),
        'stack_head': _truncate(stackTrace?.toString() ?? ''),
      },
    );
  }

  String _truncate(String value, [int maxLength = 100]) {
    return value.length <= maxLength ? value : value.substring(0, maxLength);
  }
}
