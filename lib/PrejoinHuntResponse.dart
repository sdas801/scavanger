// To parse this JSON data, do
//
//     final prejoinHuntResponse = prejoinHuntResponseFromJson(jsonString);

import 'dart:convert';

PrejoinHuntResponse prejoinHuntResponseFromJson(String str) => PrejoinHuntResponse.fromJson(json.decode(str));

String prejoinHuntResponseToJson(PrejoinHuntResponse data) => json.encode(data.toJson());

class PrejoinHuntResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    Result result;

    PrejoinHuntResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory PrejoinHuntResponse.fromJson(Map<String, dynamic> json) => PrejoinHuntResponse(
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
    String title;
    String description;
    bool isTimed;
    bool isPrized;
    bool isItemApproved;
    bool isAllowToMsgOthers;
    String maxTeam;
    String inTimeStr;
    String outTimeStr;
    String gameDuration;
    List<Prize> prizes;

    Result({
        required this.id,
        required this.gameId,
        required this.gameSessionId,
        required this.title,
        required this.description,
        required this.isTimed,
        required this.isPrized,
        required this.isItemApproved,
        required this.isAllowToMsgOthers,
        required this.maxTeam,
        required this.inTimeStr,
        required this.outTimeStr,
        required this.gameDuration,
        required this.prizes,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        gameId: json["game_id"],
        gameSessionId: json["game_session_id"],
        title: json["title"],
        description: json["description"],
        isTimed: json["is_timed"],
        isPrized: json["is_prized"],
        isItemApproved: json["is_item_approved"],
        isAllowToMsgOthers: json["is_allow_to_msg_others"],
        maxTeam: json["max_team"],
        inTimeStr: json["in_time_str"],
        outTimeStr: json["out_time_str"],
        gameDuration: json["game_duration"],
        prizes: List<Prize>.from(json["prizes"].map((x) => Prize.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_session_id": gameSessionId,
        "title": title,
        "description": description,
        "is_timed": isTimed,
        "is_prized": isPrized,
        "is_item_approved": isItemApproved,
        "is_allow_to_msg_others": isAllowToMsgOthers,
        "max_team": maxTeam,
        "in_time_str": inTimeStr,
        "out_time_str": outTimeStr,
        "game_duration": gameDuration,
        "prizes": List<dynamic>.from(prizes.map((x) => x.toJson())),
    };
}

class Prize {
    int id;
    String firstDesc;
    String firstPrizeImgUrl;
    String secondDesc;
    String secondPrizeImgUrl;
    String thirdDesc;
    String thirdPrizeImgUrl;

    Prize({
        required this.id,
        required this.firstDesc,
        required this.firstPrizeImgUrl,
        required this.secondDesc,
        required this.secondPrizeImgUrl,
        required this.thirdDesc,
        required this.thirdPrizeImgUrl,
    });

    factory Prize.fromJson(Map<String, dynamic> json) => Prize(
        id: json["id"],
        firstDesc: json["first_desc"],
        firstPrizeImgUrl: json["first_prize_img_url"],
        secondDesc: json["second_desc"],
        secondPrizeImgUrl: json["second_prize_img_url"],
        thirdDesc: json["third_desc"],
        thirdPrizeImgUrl: json["third_prize_img_url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_desc": firstDesc,
        "first_prize_img_url": firstPrizeImgUrl,
        "second_desc": secondDesc,
        "second_prize_img_url": secondPrizeImgUrl,
        "third_desc": thirdDesc,
        "third_prize_img_url": thirdPrizeImgUrl,
    };
}
