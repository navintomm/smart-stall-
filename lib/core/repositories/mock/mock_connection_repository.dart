import '../connection_repository.dart';
import '../../simulation/connection_simulator.dart';

class MockConnectionRepository implements ConnectionRepository {
  final ConnectionSimulator _simulator;

  MockConnectionRepository(this._simulator);

  @override
  Future<void> connect(String robotId, String connectionType) async {
    await _simulator.connect(robotId, connectionType);
  }

  @override
  Future<void> disconnect() async {
    await _simulator.disconnect();
  }

  @override
  Stream<String> get connectionStateStream => _simulator.connectionStateStream;
}
