abstract class ConnectionRepository {
  Future<void> connect(String robotId, String connectionType);
  Future<void> disconnect();
  Stream<String> get connectionStateStream;
}
