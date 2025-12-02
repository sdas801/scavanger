class ResponseModel {
  final String message;
  final bool success;
  final String status;
  final dynamic response;

  ResponseModel(
      {required this.message,
      required this.success,
      required this.status,
      required this.response});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
        message: json['mesasge'] ?? '',
        success: json['success']?? '',
        status: json['status']?? '',
        response: json['result']?? '');
  }
}