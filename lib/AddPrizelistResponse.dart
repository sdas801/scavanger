// To parse this JSON data, do
//
//     final addPrizelistResponse = addPrizelistResponseFromJson(jsonString);

import 'dart:convert';

AddPrizelistResponse addPrizelistResponseFromJson(String str) => AddPrizelistResponse.fromJson(json.decode(str));

String addPrizelistResponseToJson(AddPrizelistResponse data) => json.encode(data.toJson());

class AddPrizelistResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    int result;

    AddPrizelistResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory AddPrizelistResponse.fromJson(Map<String, dynamic> json) => AddPrizelistResponse(
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
