class CommunicationLogger {
  void logTx(String source, List<int> payload) {
    // print('TX [$source]: $payload');
  }

  void logRx(String source, List<int> payload) {
    // print('RX [$source]: $payload');
  }

  void logEvent(String event, String message) {
    // print('EVENT [$event]: $message');
  }

  void logError(String source, String error) {
    // print('ERROR [$source]: $error');
  }
}
