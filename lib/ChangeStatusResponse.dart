// To parse this JSON data, do
//
//     final changeStatusResponse = changeStatusResponseFromJson(jsonString);

import 'dart:convert';

ChangeStatusResponse changeStatusResponseFromJson(String str) => ChangeStatusResponse.fromJson(json.decode(str));

String changeStatusResponseToJson(ChangeStatusResponse data) => json.encode(data.toJson());

class ChangeStatusResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    int result;

    ChangeStatusResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory ChangeStatusResponse.fromJson(Map<String, dynamic> json) => ChangeStatusResponse(
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
