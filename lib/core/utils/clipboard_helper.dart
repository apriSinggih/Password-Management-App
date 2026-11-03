import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardHelper {
  static Timer? _clearTimer;

  static Future<void> copy(
    String text, {
    int clearAfterSeconds = 30,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    _clearTimer?.cancel();
    if (clearAfterSeconds > 0) {
      _clearTimer = Timer(Duration(seconds: clearAfterSeconds), () async {
        await Clipboard.setData(const ClipboardData(text: ''));
      });
    }
  }

  static void cancelTimer() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }
}
