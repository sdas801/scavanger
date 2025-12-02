// To parse this JSON data, do
//
//     final createHuntResponse = createHuntResponseFromJson(jsonString);

import 'dart:convert';

CreateHuntResponse createHuntResponseFromJson(String str) => CreateHuntResponse.fromJson(json.decode(str));

String createHuntResponseToJson(CreateHuntResponse data) => json.encode(data.toJson());

class CreateHuntResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    int result;

    CreateHuntResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory CreateHuntResponse.fromJson(Map<String, dynamic> json) => CreateHuntResponse(
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
