enum ConnectionStatus { disconnected, scanning, connecting, connected, error }

class ConnectionEvent {
  final ConnectionStatus status;
  final String? message;

  const ConnectionEvent({
    required this.status,
    this.message,
  });
}
