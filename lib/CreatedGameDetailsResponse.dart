// To parse this JSON data, do
//
//     final createdGameDetailsResponse = createdGameDetailsResponseFromJson(jsonString);

import 'dart:convert';

CreatedGameDetailsResponse createdGameDetailsResponseFromJson(String str) =>
    CreatedGameDetailsResponse.fromJson(json.decode(str));

String createdGameDetailsResponseToJson(CreatedGameDetailsResponse data) =>
    json.encode(data.toJson());

class CreatedGameDetailsResponse {
  String status;
  bool success;
  String mesasge;
  String url;
  Result result;

  CreatedGameDetailsResponse({
    required this.status,
    required this.success,
    required this.mesasge,
    required this.url,
    required this.result,
  });

  factory CreatedGameDetailsResponse.fromJson(Map<String, dynamic> json) =>
      CreatedGameDetailsResponse(
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
  String gameId;
  String gameSessionId;
  String gameType;
  String? gameImg;
  String title;
  String description;
  bool isTimed;
  bool isPrized;
  bool isItemApproved;
  bool isAllowToMsgOthers;
  int? maxTeam;
  String? inTime;
  String? outTime;
  String? gameDuration;
  String otp;
  String qrCode;
  String? gameRules;
  String status;
  String? assignFor;
  int hostBy;
  Owner owner;
  List<HuntItem> items;
  List<Prize> prizes;
  String? teamId;
  int? gamePlayId;
  String? teamname;
  String? teamimg;

  Result({
    required this.id,
    required this.gameId,
    required this.gameSessionId,
    required this.gameType,
    required this.gameImg,
    required this.title,
    required this.description,
    required this.isTimed,
    required this.isPrized,
    required this.isItemApproved,
    required this.isAllowToMsgOthers,
    required this.maxTeam,
    required this.inTime,
    required this.outTime,
    required this.gameDuration,
    required this.otp,
    required this.qrCode,
    required this.gameRules,
    required this.status,
    required this.assignFor,
    required this.hostBy,
    required this.owner,
    required this.items,
    required this.prizes,
    required this.teamId,
    required this.gamePlayId,
    required this.teamname,
    required this.teamimg,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        gameId: json["game_id"],
        gameSessionId: json["game_session_id"],
        gameType: json["game_type"],
        gameImg: json["game_img"],
        title: json["title"],
        description: json["description"],
        isTimed: json["is_timed"],
        isPrized: json["is_prized"],
        isItemApproved: json["is_item_approved"],
        isAllowToMsgOthers: json["is_allow_to_msg_others"],
        maxTeam: json["max_team"],
        inTime: json["in_time"],
        outTime: json["out_time"],
        gameDuration: json["game_duration"],
        otp: json["otp"],
        qrCode: json["qr_code"],
        gameRules: json["game_rules"],
        status: json["status"],
        assignFor: json["assign_for"],
        hostBy: json["host_by"],
        owner: Owner.fromJson(json["owner"]),
        items:
            List<HuntItem>.from(json["items"].map((x) => HuntItem.fromJson(x))),
        prizes: List<Prize>.from(json["prizes"].map((x) => Prize.fromJson(x))),
        teamId: json["teamId"],
        gamePlayId: json["gamePlayId"],
        teamname: json["teamname"],
        teamimg: json["teamimg"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_session_id": gameSessionId,
        "game_type": gameType,
        "game_img": gameImg,
        "title": title,
        "description": description,
        "is_timed": isTimed,
        "is_prized": isPrized,
        "is_item_approved": isItemApproved,
        "is_allow_to_msg_others": isAllowToMsgOthers,
        "max_team": maxTeam,
        "in_time": inTime, //!.toIso8601String(),
        "out_time": outTime, //!.toIso8601String(),
        "game_duration": gameDuration,
        "otp": otp,
        "qr_code": qrCode,
        "game_rules": gameRules,
        "status": status,
        "assign_for": assignFor,
        "host_by": hostBy,
        "owner": owner.toJson(),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "prizes": List<dynamic>.from(prizes.map((x) => x.toJson())),
        "teamId": teamId,
        "gamePlayId": gamePlayId
      };
}

class HuntItem {
  int id;
  int itemid;
  int gameId;
  String gameUniqueId;
  String? name;
  String? type;
  String? description;
  String? imgUrl;
  int? point;
  int? sequence;
  HuntItem({
    required this.id,
    required this.itemid,
    required this.gameId,
    required this.gameUniqueId,
    required this.name,
    required this.type,
    required this.description,
    required this.imgUrl,
    required this.point,
    required this.sequence,
  });

  factory HuntItem.fromJson(Map<String, dynamic> json) => HuntItem(
        id: json["id"],
        gameId: json["game_id"],
        itemid: json["itemid"],
        gameUniqueId: json["game_unique_id"],
        name: json["name"],
        type: json["type"],
        description: json["description"],
        imgUrl: json["img_url"],
        point: json["point"],
        sequence: json["sequence"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "itemid": itemid,
        "game_unique_id": gameUniqueId,
        "name": name,
        "type": type,
        "description": description,
        "img_url": imgUrl,
        "point": point,
        "sequence": sequence,
      };
}

class Owner {
  int id;
  String name;

  Owner({
    required this.id,
    required this.name,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class Prize {
  int id;
  int gameId;
  String gameUniqueId;
  String? firstDesc;
  String? firstPrizeImgUrl;
  String? secondDesc;
  String? secondPrizeImgUrl;
  String? thirdDesc;
  String? thirdPrizeImgUrl;

  Prize({
    required this.id,
    required this.gameId,
    required this.gameUniqueId,
    required this.firstDesc,
    required this.firstPrizeImgUrl,
    required this.secondDesc,
    required this.secondPrizeImgUrl,
    required this.thirdDesc,
    required this.thirdPrizeImgUrl,
  });

  factory Prize.fromJson(Map<String, dynamic> json) => Prize(
        id: json["id"],
        gameId: json["game_id"],
        gameUniqueId: json["game_unique_id"],
        firstDesc: json["first_desc"],
        firstPrizeImgUrl: json["first_prize_img_url"],
        secondDesc: json["second_desc"],
        secondPrizeImgUrl: json["second_prize_img_url"],
        thirdDesc: json["third_desc"],
        thirdPrizeImgUrl: json["third_prize_img_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_unique_id": gameUniqueId,
        "first_desc": firstDesc,
        "first_prize_img_url": firstPrizeImgUrl,
        "second_desc": secondDesc,
        "second_prize_img_url": secondPrizeImgUrl,
        "third_desc": thirdDesc,
        "third_prize_img_url": thirdPrizeImgUrl,
      };
}
