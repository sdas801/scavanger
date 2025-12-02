// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

SignupResponse signupResponseFromJson(String str) =>
    SignupResponse.fromJson(json.decode(str));

String signupResponseToJson(SignupResponse data) => json.encode(data.toJson());

class SignupResponse {
  String status;
  bool success;
  String mesasge;
  String url;
  Result result;

  SignupResponse({
    required this.status,
    required this.success,
    required this.mesasge,
    required this.url,
    required this.result,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
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
  String username;
  String email;
  String phone;
  String? countryId;
  String? countryName;
  String? stateId;
  String? stateName;
  String address;
  String city;
  String pincode;
  String userType;
  bool emailVarified;
  bool phoneVerified;
  bool userActive;

  Result({
    required this.id,
    required this.name,
    required this.uniqueId,
    required this.username,
    required this.email,
    required this.phone,
    required this.countryId,
    required this.countryName,
    required this.stateId,
    required this.stateName,
    required this.address,
    required this.city,
    required this.pincode,
    required this.userType,
    required this.emailVarified,
    required this.phoneVerified,
    required this.userActive,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        uniqueId: json["unique_id"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        countryId: json["country_id"],
        countryName: json["country_name"],
        stateId: json["state_id"],
        stateName: json["state_name"],
        address: json["address"],
        city: json["city"],
        pincode: json["pincode"],
        userType: json["user_type"],
        emailVarified: json["email_varified"],
        phoneVerified: json["phone_verified"],
        userActive: json["user_active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "unique_id": uniqueId,
        "username": username,
        "email": email,
        "phone": phone,
        "country_id": countryId,
        "country_name": countryName,
        "state_id": stateId,
        "state_name": stateName,
        "address": address,
        "city": city,
        "pincode": pincode,
        "user_type": userType,
        "email_varified": emailVarified,
        "phone_verified": phoneVerified,
        "user_active": userActive,
      };
}
