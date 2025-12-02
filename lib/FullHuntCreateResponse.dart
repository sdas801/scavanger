// To parse this JSON data, do
//
//     final fullHuntCreateResponse = fullHuntCreateResponseFromJson(jsonString);

import 'dart:convert';

FullHuntCreateResponse fullHuntCreateResponseFromJson(String str) => FullHuntCreateResponse.fromJson(json.decode(str));

String fullHuntCreateResponseToJson(FullHuntCreateResponse data) => json.encode(data.toJson());

class FullHuntCreateResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    int result;

    FullHuntCreateResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory FullHuntCreateResponse.fromJson(Map<String, dynamic> json) => FullHuntCreateResponse(
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
