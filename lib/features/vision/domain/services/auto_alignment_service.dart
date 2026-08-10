import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/repositories/robot_repository.dart';
import '../../../../core/communication/protocol/catalogues/command_catalog.dart';
import '../models/alignment_result.dart';
import '../../presentation/providers/alignment_provider.dart';

final autoAlignmentServiceProvider = Provider<AutoAlignmentService>((ref) {
  final service = AutoAlignmentService(
    ref.watch(robotRepositoryProvider),
  );
  
  // Listen to smoothed alignment updates
  ref.listen<AlignmentResult>(smoothedAlignmentProvider, (previous, next) {
    service.processAlignment(next);
  });
  
  return service;
});

class AutoAlignmentService {
  final RobotRepository _robot;
  
  bool _isAligning = false;
  String _lastCommand = '';
  DateTime _lastCommandTime = DateTime.now();

  AutoAlignmentService(this._robot);

  void startAutoAlignment() {
    _isAligning = true;
  }

  void stopAutoAlignment() {
    _isAligning = false;
    _sendCommand(CommandCatalog.stop.name, {});
  }

  void processAlignment(AlignmentResult alignment) {
    if (!_isAligning) return;
    
    // Throttle commands to avoid flooding the network
    if (DateTime.now().difference(_lastCommandTime).inMilliseconds < 200) {
      return;
    }

    if (alignment.status == AlignmentStatus.markerLost || alignment.status == AlignmentStatus.error) {
      _sendCommand(CommandCatalog.stop.name, {});
      return;
    }

    if (alignment.status == AlignmentStatus.ready) {
      _sendCommand(CommandCatalog.stop.name, {});
      _isAligning = false; // Successfully aligned
      return;
    }

    // Determine primary error to fix (prioritize horizontal alignment first, then distance)
    if (alignment.horizontalErrorM.abs() > 0.05) {
      // Need to turn
      final speed = (alignment.horizontalErrorM.abs() * 50).clamp(10, 30).toInt();
      if (alignment.horizontalErrorM > 0) {
        _sendCommand(CommandCatalog.turnRight.name, {'speed': speed});
      } else {
        _sendCommand(CommandCatalog.turnLeft.name, {'speed': speed});
      }
    } else if (alignment.distanceErrorM.abs() > 0.1) {
      // Need to move forward/backward
      final speed = (alignment.distanceErrorM.abs() * 50).clamp(10, 40).toInt();
      if (alignment.distanceErrorM > 0) {
        // Target is further than target distance -> move forward
        _sendCommand(CommandCatalog.moveForward.name, {'speed': speed});
      } else {
        // Target is closer than target distance -> move backward
        _sendCommand(CommandCatalog.moveBackward.name, {'speed': speed});
      }
    } else {
      _sendCommand(CommandCatalog.stop.name, {});
    }
  }
  
  void _sendCommand(String command, Map<String, dynamic> payload) {
    if (_lastCommand == command && command == CommandCatalog.stop.name) {
      return; // Don't spam stop commands
    }
    
    _robot.sendCommand(command, payload);
    _lastCommand = command;
    _lastCommandTime = DateTime.now();
  }
}
