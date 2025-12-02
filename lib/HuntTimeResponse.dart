// To parse this JSON data, do
//
//     final huntTimeResponse = huntTimeResponseFromJson(jsonString);

import 'dart:convert';

HuntTimeResponse huntTimeResponseFromJson(String str) => HuntTimeResponse.fromJson(json.decode(str));

String huntTimeResponseToJson(HuntTimeResponse data) => json.encode(data.toJson());

class HuntTimeResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    int result;

    HuntTimeResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory HuntTimeResponse.fromJson(Map<String, dynamic> json) => HuntTimeResponse(
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
