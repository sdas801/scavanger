// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  String status;
  bool success;
  String mesasge;
  String url;
  LoginResult result;

  LoginResponse({
    required this.status,
    required this.success,
    required this.mesasge,
    required this.url,
    required this.result,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: LoginResult.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": result.toJson(),
      };
}

class LoginResult {
  int id;
  String name;
  String? username;
  String? uniqueId;
  String? userType;
  String? email;
  String? phone;
  int? countryId;
  String? countryName;
  int? stateId;
  String? stateName;
  String? city;
  String? address;
  String? pincode;
  dynamic userImg;
  bool emailVarified;
  bool phoneVerified;
  bool userActive;
  String token;
  PolicyResult? policy;

  LoginResult({
    required this.id,
    required this.name,
    required this.username,
    required this.uniqueId,
    required this.userType,
    required this.email,
    required this.phone,
    required this.countryId,
    required this.countryName,
    required this.stateId,
    required this.stateName,
    required this.city,
    required this.address,
    required this.pincode,
    required this.userImg,
    required this.emailVarified,
    required this.phoneVerified,
    required this.userActive,
    required this.token,
    this.policy,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        uniqueId: json["unique_id"],
        userType: json["user_type"],
        email: json["email"],
        phone: json["phone"],
        countryId: json["country_id"],
        countryName: json["country_name"],
        stateId: json["state_id"],
        stateName: json["state_name"],
        city: json["city"],
        address: json["address"],
        pincode: json["pincode"],
        userImg: json["user_img"],
        emailVarified: json["email_varified"],
        phoneVerified: json["phone_verified"],
        userActive: json["user_active"],
        token: json["token"],
        policy: json["policy"] != null
            ? PolicyResult.fromJson(json["policy"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "unique_id": uniqueId,
        "user_type": userType,
        "email": email,
        "phone": phone,
        "country_id": countryId,
        "country_name": countryName,
        "state_id": stateId,
        "state_name": stateName,
        "city": city,
        "address": address,
        "pincode": pincode,
        "user_img": userImg,
        "email_varified": emailVarified,
        "phone_verified": phoneVerified,
        "user_active": userActive,
        "token": token,
        "policy": policy?.toJson(),
      };
}

class PolicyResult {
  int user_id;
  int id;
  String name;
  String? description;
  dynamic price_monthly;
  dynamic price_annually;
  String? planType;
  dynamic maxHunts;
  dynamic maxChallenges;
  dynamic maxHuntItems;
  dynamic maxChallengeItems;
  dynamic maxCreatedItems;
  dynamic maxPurchasedItems;
  dynamic maxHuntTeams;
  dynamic video_available;
  int isRelaunch;
  String createdTime;
  String endTime;
  dynamic startDate;
  dynamic expiryDate;
  int? is_renew;
  dynamic stripe_id;

  PolicyResult({
    required this.user_id,
    required this.id,
    required this.name,
    required this.description,
    required this.price_monthly,
    required this.price_annually,
    required this.planType,
    required this.maxHunts,
    required this.maxChallenges,
    required this.maxHuntItems,
    required this.maxChallengeItems,
    required this.maxCreatedItems,
    required this.maxPurchasedItems,
    required this.maxHuntTeams,
    required this.video_available,
    required this.isRelaunch,
    required this.createdTime,
    required this.endTime,
    required this.startDate,
    required this.expiryDate,
    required this.is_renew,
    required this.stripe_id,
  });

  factory PolicyResult.fromJson(Map<String, dynamic> json) => PolicyResult(
        user_id: json["user_id"],
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price_monthly: json["price_monthly"],
        price_annually: json["price_annually"],
        planType: json["plan_type"],
        maxHunts: json["max_hunts"],
        maxChallenges: json["max_challenges"],
        maxHuntItems: json["max_hunt_items"],
        maxChallengeItems: json["max_challenge_items"],
        maxCreatedItems: json["max_created_items"],
        maxPurchasedItems: json["max_purchased_items"],
        maxHuntTeams: json["max_hunt_teams"],
        video_available: json["video_available"],
        isRelaunch: json["is_relaunch"],
        createdTime: json["created_at"],
        endTime: json["updated_at"],
        startDate: json["start_date"],
        expiryDate: json["end_date"],
        is_renew: json["is_renew"],
        stripe_id: json["stripe_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": user_id,
        "id": id,
        "name": name,
        "description": description,
        "price_monthly": price_monthly,
        "price_annually": price_annually,
        "plan_type": planType,
        "max_hunts": maxHunts,
        "max_challenges": maxChallenges,
        "max_hunt_items": maxHuntItems,
        "max_challenge_items": maxChallengeItems,
        "max_created_items": maxCreatedItems,
        "max_purchased_items": maxPurchasedItems,
        "max_hunt_teams": maxHuntTeams,
        "video_available": video_available,
        "is_relaunch": isRelaunch,
        "created_at": createdTime,
        "updated_at": endTime,
        "start_date": startDate,
        "end_date": expiryDate,
        "is_renew": is_renew,
        "stripe_id": stripe_id,
      };
}

class UpdateResult {
  int id;
  String name;
  String? username;
  String? uniqueId;
  String? userType;
  String? email;
  String? phone;
  int? countryId;
  String? countryName;
  int? stateId;
  String? stateName;
  String? city;
  String? address;
  String? pincode;
  dynamic userImg;
  bool emailVarified;
  bool phoneVerified;
  bool userActive;

  UpdateResult({
    required this.id,
    required this.name,
    required this.username,
    required this.uniqueId,
    required this.userType,
    required this.email,
    required this.phone,
    required this.countryId,
    required this.countryName,
    required this.stateId,
    required this.stateName,
    required this.city,
    required this.address,
    required this.pincode,
    required this.userImg,
    required this.emailVarified,
    required this.phoneVerified,
    required this.userActive,
  });

  factory UpdateResult.fromJson(Map<String, dynamic> json) => UpdateResult(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        uniqueId: json["unique_id"],
        userType: json["user_type"],
        email: json["email"],
        phone: json["phone"],
        countryId: json["country_id"],
        countryName: json["country_name"],
        stateId: json["state_id"],
        stateName: json["state_name"],
        city: json["city"],
        address: json["address"],
        pincode: json["pincode"],
        userImg: json["user_img"],
        emailVarified: json["email_varified"],
        phoneVerified: json["phone_verified"],
        userActive: json["user_active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "unique_id": uniqueId,
        "user_type": userType,
        "email": email,
        "phone": phone,
        "country_id": countryId,
        "country_name": countryName,
        "state_id": stateId,
        "state_name": stateName,
        "city": city,
        "address": address,
        "pincode": pincode,
        "user_img": userImg,
        "email_varified": emailVarified,
        "phone_verified": phoneVerified,
        "user_active": userActive,
      };
}
