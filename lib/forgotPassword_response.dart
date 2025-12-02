// To parse this JSON data, do
//
//     final forgotPasswordResponse = forgotPasswordResponseFromJson(jsonString);

import 'dart:convert';

ForgotPasswordResponse forgotPasswordResponseFromJson(String str) => ForgotPasswordResponse.fromJson(json.decode(str));

String forgotPasswordResponseToJson(ForgotPasswordResponse data) => json.encode(data.toJson());

class ForgotPasswordResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    Result result;

    ForgotPasswordResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) => ForgotPasswordResponse(
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
    int id;
   

    Result({
        required this.id,
       
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
       
    );

    Map<String, dynamic> toJson() => {
        "id": id,
       
    };
}
