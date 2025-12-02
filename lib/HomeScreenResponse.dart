// To parse this JSON data, do
//
//     final homeScreenResponse = homeScreenResponseFromJson(jsonString);

import 'dart:convert';

HomeScreenResponse homeScreenResponseFromJson(String str) =>
    HomeScreenResponse.fromJson(json.decode(str));

String homeScreenResponseToJson(HomeScreenResponse data) =>
    json.encode(data.toJson());

class HomeScreenResponse {
  String status;
  bool success;
  String mesasge;
  String url;
  List<Result> result;

  HomeScreenResponse({
    required this.status,
    required this.success,
    required this.mesasge,
    required this.url,
    required this.result,
  });

  factory HomeScreenResponse.fromJson(Map<String, dynamic> json) =>
      HomeScreenResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class Result {
  int id;
  String gameId;
  String? gameSessionId;
  String gameType;
  String title;
  String description;
  bool? isTimed;
  bool? isPrized;
  bool? isItemApproved;
  bool? isAllowToMsgOthers;
  dynamic maxTeam;
  String? inTime;
  String? outTime;
  dynamic gameDuration;
  String? otp;
  dynamic qrCode;
  String? gameRules;
  String status;
  int hostBy;
  // Owner? owner;
  List<dynamic>? items;
  List<Prize>? prizes;
  String? gameImg;
  int? isHost;
  String? teamId;
  int? gamePlayId;
  int? isprocessed;
  String? gamePlayStatus;
  int? uploadedItems;
  int? totalItems;

  Result(
      {required this.id,
      required this.gameId,
      required this.gameSessionId,
      required this.gameType,
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
      required this.hostBy,
      // required this.owner,
      required this.items,
      required this.prizes,
      required this.gameImg,
      required this.teamId,
      this.isHost = 1,
      this.gamePlayId = 0,
      this.isprocessed = 0,
      this.gamePlayStatus = "0",
      this.totalItems = 0,
      this.uploadedItems = 0});

  factory Result.fromJson(Map<String, dynamic> json) {
    try{
      return Result(
        id: json["id"],
        gameId: json["game_id"],
        gameSessionId: json["game_session_id"],
        gameType: json["game_type"],
        gameImg: json["game_img"],
        title: json["title"],
        description: json["description"],
        isTimed: json["is_timed"] == 1,
        isPrized: json["is_prized"] == 1,
        isItemApproved: json["is_item_approved"] == 1,
        isAllowToMsgOthers: json["is_allow_to_msg_others"] == 1,
        maxTeam: json["max_team"],
        inTime: json["in_time"],
        outTime: json["out_time"],
        gameDuration: json["game_duration"],
        otp: json["otp"],
        qrCode: json["qr_code"],
        gameRules: json["game_rules"],
        status: json["status"],
        hostBy: json["host_by"],
        // owner: Owner.fromJson(json["owner"]),
        items: List<dynamic>.from(json["items"].map((x) => x)),
        prizes: List<Prize>.from(json["prizes"].map((x) => Prize.fromJson(x))),
        isHost: json["isHost"],
        teamId: json["team_id"],
        gamePlayId: json["gamePlayId"],
        isprocessed: json["isprocessed"] == null ? 0 : int.tryParse(json["isprocessed"]) ?? 0,
        gamePlayStatus: json["gamePlayStatus"],
        totalItems: json["totalItems"] ?? 0,
        uploadedItems: json["uploadedItems"] ?? 0,
      );
    } catch(e) {
      print(e);
      return Result(
        id: json["id"],
        gameId: json["game_id"],
        gameSessionId: json["game_session_id"],
        gameType: json["game_type"],
        gameImg: json["game_img"],
        title: json["title"],
        description: json["description"],
        isTimed: json["is_timed"] == 1,
        isPrized: json["is_prized"] == 1,
        isItemApproved: json["is_item_approved"] == 1,
        isAllowToMsgOthers: json["is_allow_to_msg_others"] == 1,
        maxTeam: json["max_team"],
        inTime: json["in_time"],
        outTime: json["out_time"],
        gameDuration: json["game_duration"],
        otp: json["otp"],
        qrCode: json["qr_code"],
        gameRules: json["game_rules"],
        status: json["status"],
        hostBy: json["host_by"],
        // owner: Owner.fromJson(json["owner"]),
        items: List<dynamic>.from(json["items"].map((x) => x)),
        prizes: List<Prize>.from(json["prizes"].map((x) => Prize.fromJson(x))),
        isHost: json["isHost"],
        teamId: json["team_id"],
        gamePlayId: json["gamePlayId"],
        isprocessed: json["isprocessed"] ?? 0,
        gamePlayStatus: json["gamePlayStatus"],
        totalItems: json["totalItems"] ?? 0,
        uploadedItems: json["uploadedItems"] ?? 0,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_session_id": gameSessionId,
        "game_type": gameType,
        "game_img,": gameImg,
        "title": title,
        "description": description,
        "is_timed": isTimed,
        "is_prized": isPrized,
        "is_item_approved": isItemApproved,
        "is_allow_to_msg_others": isAllowToMsgOthers,
        "max_team": maxTeam,
        "in_time": inTime,
        "out_time": outTime,
        // "game_duration": gameDuration,
        "otp": otp,
        "qr_code": qrCode,
        "game_rules": gameRules,
        "status": status,
        "host_by": hostBy,
        // "owner": owner?.toJson(),
        "items": [],
        "prizes": [],
        "team_id": teamId,
        "isprocessed": isprocessed,
        "totalItems": totalItems,
        "uploadedItems": uploadedItems
      };
}

class GameModel {
  int id;
  String gameId;
  String gameSessionId;
  dynamic gameType;
  dynamic title;
  dynamic description;
  bool? isTimed;
  bool? isPrized;
  bool? isItemApproved;
  bool? isAllowToMsgOthers;
  dynamic maxTeam;
  dynamic inTime;
  dynamic outTime;
  dynamic gameDuration;
  dynamic otp;
  dynamic qrCode;
  dynamic gameRules;
  String status;
  int hostBy;
  Owner? owner;
  List<dynamic>? items;
  List<Prize>? prizes;
  String? gameImg;

  GameModel({
    required this.id,
    required this.gameId,
    required this.gameSessionId,
    required this.gameType,
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
    required this.hostBy,
    required this.owner,
    required this.items,
    required this.prizes,
    required this.gameImg,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) => GameModel(
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
        hostBy: json["host_by"],
        owner: null,
        items: [],
        prizes: [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_session_id": gameSessionId,
        "game_type": gameType,
        "game_img,": gameImg,
        "title": title,
        "description": description,
        "is_timed": isTimed,
        "is_prized": isPrized,
        "is_item_approved": isItemApproved,
        "is_allow_to_msg_others": isAllowToMsgOthers,
        "max_team": maxTeam,
        "in_time": inTime,
        "out_time": outTime,
        "game_duration": gameDuration,
        "otp": otp,
        "qr_code": qrCode,
        "game_rules": gameRules,
        "status": status,
        "host_by": hostBy,
        "owner": owner?.toJson(),
        "items": List<dynamic>.from(items!.map((x) => x)),
        "prizes": List<dynamic>.from(prizes!.map((x) => x.toJson())),
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
  dynamic firstDesc;
  dynamic firstPrizeImgUrl;
  dynamic secondDesc;
  dynamic secondPrizeImgUrl;
  dynamic thirdDesc;
  dynamic thirdPrizeImgUrl;

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
