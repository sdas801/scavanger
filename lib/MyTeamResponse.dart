// To parse this JSON data, do
//
//     final myTeamResponse = myTeamResponseFromJson(jsonString);

import 'dart:convert';

MyTeamResponse myTeamResponseFromJson(String str) =>
    MyTeamResponse.fromJson(json.decode(str));

String myTeamResponseToJson(MyTeamResponse data) => json.encode(data.toJson());

class MyTeamResponse {
  String status;
  bool success;
  String mesasge;
  String url;
  List<ResultMyteam> result;

  MyTeamResponse({
    required this.status,
    required this.success,
    required this.mesasge,
    required this.url,
    required this.result,
  });

  factory MyTeamResponse.fromJson(Map<String, dynamic> json) => MyTeamResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: List<ResultMyteam>.from(
            json["result"].map((x) => ResultMyteam.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class ResultMyteam {
  int id;
  String name;
  String? userImg;

  ResultMyteam({
    required this.id,
    required this.name,
    required this.userImg,
  });

  factory ResultMyteam.fromJson(Map<String, dynamic> json) => ResultMyteam(
        id: json["id"],
        name: json["name"],
        userImg: json["user_img"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "user_img": userImg,
      };
}
