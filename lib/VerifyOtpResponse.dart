// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) => VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) => json.encode(data.toJson());

class VerifyOtpResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    Result result;

    VerifyOtpResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
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
    String name;
    String uniqueId;
    String email;
    String phone;
    String otp;

    Result({
        required this.id,
        required this.name,
        required this.uniqueId,
        required this.email,
        required this.phone,
        required this.otp,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        uniqueId: json["unique_id"],
        email: json["email"],
        phone: json["phone"],
        otp: json["otp"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "unique_id": uniqueId,
        "email": email,
        "phone": phone,
        "otp": otp,
    };
}
