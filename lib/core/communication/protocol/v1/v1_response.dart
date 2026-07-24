class V1Response {
  final int commandId;
  final bool isSuccess;
  final int errorCode;
  final String message;
  final Map<String, dynamic>? data;

  const V1Response({
    required this.commandId,
    required this.isSuccess,
    this.errorCode = 0,
    this.message = '',
    this.data,
  });

  factory V1Response.fromJson(Map<String, dynamic> json) {
    return V1Response(
      commandId: json['commandId'] as int? ?? -1,
      isSuccess: json['isSuccess'] as bool? ?? false,
      errorCode: json['errorCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
