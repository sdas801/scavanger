// To parse this JSON data, do
//
//     final uploadImageResponse = uploadImageResponseFromJson(jsonString);

import 'dart:convert';

UploadImageResponse uploadImageResponseFromJson(String str) => UploadImageResponse.fromJson(json.decode(str));

String uploadImageResponseToJson(UploadImageResponse data) => json.encode(data.toJson());

class UploadImageResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    Result result;

    UploadImageResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory UploadImageResponse.fromJson(Map<String, dynamic> json) => UploadImageResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": result.toJson(),
    };
}

class Result {
    String url;
    String secureUrl;

    Result({
        required this.url,
        required this.secureUrl,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        url: json["url"],
        secureUrl: json["secure_url"],
    );

    Map<String, dynamic> toJson() => {
        "url": url,
        "secure_url": secureUrl,
    };
}
