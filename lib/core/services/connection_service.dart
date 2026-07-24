abstract class ConnectionService {
  /// Initialize the connection service (e.g. bluetooth, wifi, MQTT setup)
  Future<void> init();
  
  /// Connect to the specified robot/stall ID
  Future<bool> connect(String stallId);
  
  /// Disconnect from the currently connected stall
  Future<void> disconnect();
  
  /// Check if currently connected
  bool get isConnected;
  
  /// Get a stream of connection status changes
  Stream<bool> get connectionStatusStream;
  
  /// Send a command to the stall
  Future<bool> sendCommand(String command, [Map<String, dynamic>? payload]);
}
