// To parse this JSON data, do
//
//     final uploadItemResponse = uploadItemResponseFromJson(jsonString);

import 'dart:convert';

UploadItemResponse uploadItemResponseFromJson(String str) => UploadItemResponse.fromJson(json.decode(str));

String uploadItemResponseToJson(UploadItemResponse data) => json.encode(data.toJson());

class UploadItemResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    int result;

    UploadItemResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory UploadItemResponse.fromJson(Map<String, dynamic> json) => UploadItemResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: json["result"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": result,
    };
}
