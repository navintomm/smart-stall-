enum ErrorSeverity { info, warning, critical, fatal }

class ErrorDefinition {
  final int code;
  final String name;
  final ErrorSeverity severity;
  final String description;
  final String recoverySuggestion;

  const ErrorDefinition({
    required this.code,
    required this.name,
    required this.severity,
    required this.description,
    required this.recoverySuggestion,
  });
}

class ErrorCatalog {
  static const unknownCommand = ErrorDefinition(code: 1001, name: 'UNKNOWN_COMMAND', severity: ErrorSeverity.warning, description: 'Command ID not recognized', recoverySuggestion: 'Verify protocol version');
  static const invalidPayload = ErrorDefinition(code: 1002, name: 'INVALID_PAYLOAD', severity: ErrorSeverity.warning, description: 'Missing or malformed arguments', recoverySuggestion: 'Check command parameters');
  static const timeout = ErrorDefinition(code: 1003, name: 'TIMEOUT', severity: ErrorSeverity.warning, description: 'Operation took too long', recoverySuggestion: 'Retry command');
  static const crcFailure = ErrorDefinition(code: 1004, name: 'CRC_FAILURE', severity: ErrorSeverity.warning, description: 'Checksum mismatch', recoverySuggestion: 'Packet dropped, will retry automatically');
  
  static const motorFault = ErrorDefinition(code: 2001, name: 'MOTOR_FAULT', severity: ErrorSeverity.critical, description: 'Overcurrent or stall detected on motor', recoverySuggestion: 'Clear obstruction and recalibrate');
  static const lowBattery = ErrorDefinition(code: 2002, name: 'LOW_BATTERY', severity: ErrorSeverity.warning, description: 'Battery below safe threshold', recoverySuggestion: 'Return to dock');
  static const emergencyActive = ErrorDefinition(code: 2003, name: 'EMERGENCY_ACTIVE', severity: ErrorSeverity.info, description: 'Robot is currently locked by E-Stop', recoverySuggestion: 'Release E-Stop to resume operations');
  static const pumpFailure = ErrorDefinition(code: 2004, name: 'PUMP_FAILURE', severity: ErrorSeverity.critical, description: 'Pump motor blocked or dry', recoverySuggestion: 'Check fluid lines');
  static const brushFailure = ErrorDefinition(code: 2005, name: 'BRUSH_FAILURE', severity: ErrorSeverity.critical, description: 'Brush motor jammed', recoverySuggestion: 'Clean brush assembly');
  
  static const commLost = ErrorDefinition(code: 3001, name: 'COMMUNICATION_LOST', severity: ErrorSeverity.fatal, description: 'Heartbeat timeout', recoverySuggestion: 'Re-establish connection');

  static const List<ErrorDefinition> allErrors = [
    unknownCommand, invalidPayload, timeout, crcFailure,
    motorFault, lowBattery, emergencyActive, pumpFailure, brushFailure,
    commLost
  ];

  static ErrorDefinition? getByCode(int code) {
    try {
      return allErrors.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }
}
