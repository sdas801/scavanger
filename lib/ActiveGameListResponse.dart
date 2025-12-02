// To parse this JSON data, do
//
//     final activeGameListResponse = activeGameListResponseFromJson(jsonString);

import 'dart:convert';

ActiveGameListResponse activeGameListResponseFromJson(String str) => ActiveGameListResponse.fromJson(json.decode(str));

String activeGameListResponseToJson(ActiveGameListResponse data) => json.encode(data.toJson());

class ActiveGameListResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    List<ResultActivehunt> result;

    ActiveGameListResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory ActiveGameListResponse.fromJson(Map<String, dynamic> json) => ActiveGameListResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: List<ResultActivehunt>.from(json["result"].map((x) => ResultActivehunt.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
    };
}

class ResultActivehunt {
    int id;
    String gameId;
    String gameSessionId;
    String gameType;
    String title;
    String description;
    bool isTimed;
    bool isPrized;
    bool isItemApproved;
    bool isAllowToMsgOthers;
    int maxTeam;
    DateTime inTime;
    DateTime outTime;
    String gameDuration;
    String otp;
    String qrCode;
    String gameRules;
    String status;
    int hostBy;
    Owner owner;
    List<Item> items;
    List<Prize> prizes;

    ResultActivehunt({
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
    });

    factory ResultActivehunt.fromJson(Map<String, dynamic> json) => ResultActivehunt(
        id: json["id"],
        gameId: json["game_id"],
        gameSessionId: json["game_session_id"],
        gameType: json["game_type"],
        title: json["title"],
        description: json["description"],
        isTimed: json["is_timed"],
        isPrized: json["is_prized"],
        isItemApproved: json["is_item_approved"],
        isAllowToMsgOthers: json["is_allow_to_msg_others"],
        maxTeam: json["max_team"],
        inTime: DateTime.parse(json["in_time"]),
        outTime: DateTime.parse(json["out_time"]),
        gameDuration: json["game_duration"],
        otp: json["otp"],
        qrCode: json["qr_code"],
        gameRules: json["game_rules"],
        status: json["status"],
        hostBy: json["host_by"],
        owner: Owner.fromJson(json["owner"]),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        prizes: List<Prize>.from(json["prizes"].map((x) => Prize.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_session_id": gameSessionId,
        "game_type": gameType,
        "title": title,
        "description": description,
        "is_timed": isTimed,
        "is_prized": isPrized,
        "is_item_approved": isItemApproved,
        "is_allow_to_msg_others": isAllowToMsgOthers,
        "max_team": maxTeam,
        "in_time": inTime.toIso8601String(),
        "out_time": outTime.toIso8601String(),
        "game_duration": gameDuration,
        "otp": otp,
        "qr_code": qrCode,
        "game_rules": gameRules,
        "status": status,
        "host_by": hostBy,
        "owner": owner.toJson(),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "prizes": List<dynamic>.from(prizes.map((x) => x.toJson())),
    };
}

class Item {
    int id;
    int gameId;
    String gameUniqueId;
    String name;
    String description;
    String imgUrl;
    int point;

    Item({
        required this.id,
        required this.gameId,
        required this.gameUniqueId,
        required this.name,
        required this.description,
        required this.imgUrl,
        required this.point,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        gameId: json["game_id"],
        gameUniqueId: json["game_unique_id"],
        name: json["name"],
        description: json["description"],
        imgUrl: json["img_url"],
        point: json["point"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_unique_id": gameUniqueId,
        "name": name,
        "description": description,
        "img_url": imgUrl,
        "point": point,
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
    String firstDesc;
    String firstPrizeImgUrl;
    String secondDesc;
    String secondPrizeImgUrl;
    String thirdDesc;
    String thirdPrizeImgUrl;

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
