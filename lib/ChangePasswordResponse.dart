// To parse this JSON data, do
//
//     final changePasswordResponse = changePasswordResponseFromJson(jsonString);

import 'dart:convert';

ChangePasswordResponse changePasswordResponseFromJson(String str) => ChangePasswordResponse.fromJson(json.decode(str));

String changePasswordResponseToJson(ChangePasswordResponse data) => json.encode(data.toJson());

class ChangePasswordResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    Result result;

    ChangePasswordResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) => ChangePasswordResponse(
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
    bool userActive;

    Result({
        required this.id,
        required this.name,
        required this.uniqueId,
        required this.email,
        required this.phone,
        required this.userActive,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        uniqueId: json["unique_id"],
        email: json["email"],
        phone: json["phone"],
        userActive: json["user_active"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "unique_id": uniqueId,
        "email": email,
        "phone": phone,
        "user_active": userActive,
    };
}
