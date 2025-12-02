// To parse this JSON data, do
//
//     final createHunt2Response = createHunt2ResponseFromJson(jsonString);

import 'dart:convert';

CreateHunt2Response createHunt2ResponseFromJson(String str) => CreateHunt2Response.fromJson(json.decode(str));

String createHunt2ResponseToJson(CreateHunt2Response data) => json.encode(data.toJson());

class CreateHunt2Response {
    String status;
    bool success;
    String mesasge;
    String url;
    int result;

    CreateHunt2Response({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory CreateHunt2Response.fromJson(Map<String, dynamic> json) => CreateHunt2Response(
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
