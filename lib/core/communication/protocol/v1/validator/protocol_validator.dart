class ProtocolValidator {
  static const int MAX_PAYLOAD_SIZE = 1024; // 1 KB max payload

  static bool validateCommandSize(String jsonString) {
    return jsonString.length <= MAX_PAYLOAD_SIZE;
  }

  static bool validateRequiredFields(Map<String, dynamic> json) {
    return json.containsKey('commandId') && 
           json.containsKey('commandType') && 
           json.containsKey('timestamp');
  }

  static int calculateChecksum(String payload) {
    // Placeholder for future CRC32/Adler32 Checksum implementation
    int sum = 0;
    for (int i = 0; i < payload.length; i++) {
      sum += payload.codeUnitAt(i);
    }
    return sum % 256;
  }
}
