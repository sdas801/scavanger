import 'dart:async';

class BackgroundCancelled implements Exception {
  final String reason;
  BackgroundCancelled([this.reason = 'Cancelled due to background']);
  @override
  String toString() => 'BackgroundCancelled: $reason';
}

class RequestGate {
  RequestGate._();
  static final RequestGate instance = RequestGate._();

  bool _isForeground = true;
  int _sessionId = 0; // increments whenever we background (to drop late responses)
  Duration resumeDebounce = const Duration(milliseconds: 250);

  bool get isForeground => _isForeground;
  int get sessionId => _sessionId;

  void goBackground() {
    _isForeground = false;
    // bump session so late responses are ignored
    _sessionId++;
  }

  Future<void> goForeground() async {
    _isForeground = true;
    if (resumeDebounce > Duration.zero) {
      // tiny cooldown to avoid thundering herd
      await Future<void>.delayed(resumeDebounce);
    }
  }

  /// Throw if we are in background
  void ensureForeground() {
    if (!_isForeground) {
      throw BackgroundCancelled();
    }
  }
}
