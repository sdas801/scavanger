// To parse this JSON data, do
//
//     final gameStepStartResponse = gameStepStartResponseFromJson(jsonString);

import 'dart:convert';

GameStepStartResponse gameStepStartResponseFromJson(String str) => GameStepStartResponse.fromJson(json.decode(str));

String gameStepStartResponseToJson(GameStepStartResponse data) => json.encode(data.toJson());

class GameStepStartResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    Result result;

    GameStepStartResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory GameStepStartResponse.fromJson(Map<String, dynamic> json) => GameStepStartResponse(
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
    Game game;
    GamePrizes gamePrizes;

    Result({
        required this.game,
        required this.gamePrizes,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        game: Game.fromJson(json["game"]),
        gamePrizes: GamePrizes.fromJson(json["gamePrizes"]),
    );

    Map<String, dynamic> toJson() => {
        "game": game.toJson(),
        "gamePrizes": gamePrizes.toJson(),
    };
}

class Game {
    dynamic gameType;
    bool isTimed;
    bool isPrized;
    bool isItemApproved;
    bool isAllowToMsgOthers;
    dynamic maxTeam;
    dynamic inTime;
    dynamic inTimeStr;
    dynamic outTime;
    dynamic outTimeStr;
    dynamic gameDuration;
    dynamic otp;
    dynamic qrCode;
    dynamic gameRules;
    String status;
    int id;
    String gameId;
    String gameSessionId;
    int hostBy;
    DateTime updatedAt;
    DateTime createdAt;

    Game({
        required this.gameType,
        required this.isTimed,
        required this.isPrized,
        required this.isItemApproved,
        required this.isAllowToMsgOthers,
        required this.maxTeam,
        required this.inTime,
        required this.inTimeStr,
        required this.outTime,
        required this.outTimeStr,
        required this.gameDuration,
        required this.otp,
        required this.qrCode,
        required this.gameRules,
        required this.status,
        required this.id,
        required this.gameId,
        required this.gameSessionId,
        required this.hostBy,
        required this.updatedAt,
        required this.createdAt,
    });

    factory Game.fromJson(Map<String, dynamic> json) => Game(
        gameType: json["game_type"],
        isTimed: json["is_timed"],
        isPrized: json["is_prized"],
        isItemApproved: json["is_item_approved"],
        isAllowToMsgOthers: json["is_allow_to_msg_others"],
        maxTeam: json["max_team"],
        inTime: json["in_time"],
        inTimeStr: json["in_time_str"],
        outTime: json["out_time"],
        outTimeStr: json["out_time_str"],
        gameDuration: json["game_duration"],
        otp: json["otp"],
        qrCode: json["qr_code"],
        gameRules: json["game_rules"],
        status: json["status"],
        id: json["id"],
        gameId: json["game_id"],
        gameSessionId: json["game_session_id"],
        hostBy: json["host_by"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        createdAt: DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "game_type": gameType,
        "is_timed": isTimed,
        "is_prized": isPrized,
        "is_item_approved": isItemApproved,
        "is_allow_to_msg_others": isAllowToMsgOthers,
        "max_team": maxTeam,
        "in_time": inTime,
        "in_time_str": inTimeStr,
        "out_time": outTime,
        "out_time_str": outTimeStr,
        "game_duration": gameDuration,
        "otp": otp,
        "qr_code": qrCode,
        "game_rules": gameRules,
        "status": status,
        "id": id,
        "game_id": gameId,
        "game_session_id": gameSessionId,
        "host_by": hostBy,
        "updatedAt": updatedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
    };
}

class GamePrizes {
    dynamic firstDesc;
    dynamic firstPrizeImgUrl;
    dynamic secondDesc;
    dynamic secondPrizeImgUrl;
    dynamic thirdDesc;
    dynamic thirdPrizeImgUrl;
    int id;
    int gameId;
    String gameUniqueId;
    DateTime updatedAt;
    DateTime createdAt;

    GamePrizes({
        required this.firstDesc,
        required this.firstPrizeImgUrl,
        required this.secondDesc,
        required this.secondPrizeImgUrl,
        required this.thirdDesc,
        required this.thirdPrizeImgUrl,
        required this.id,
        required this.gameId,
        required this.gameUniqueId,
        required this.updatedAt,
        required this.createdAt,
    });

    factory GamePrizes.fromJson(Map<String, dynamic> json) => GamePrizes(
        firstDesc: json["first_desc"],
        firstPrizeImgUrl: json["first_prize_img_url"],
        secondDesc: json["second_desc"],
        secondPrizeImgUrl: json["second_prize_img_url"],
        thirdDesc: json["third_desc"],
        thirdPrizeImgUrl: json["third_prize_img_url"],
        id: json["id"],
        gameId: json["game_id"],
        gameUniqueId: json["game_unique_id"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        createdAt: DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "first_desc": firstDesc,
        "first_prize_img_url": firstPrizeImgUrl,
        "second_desc": secondDesc,
        "second_prize_img_url": secondPrizeImgUrl,
        "third_desc": thirdDesc,
        "third_prize_img_url": thirdPrizeImgUrl,
        "id": id,
        "game_id": gameId,
        "game_unique_id": gameUniqueId,
        "updatedAt": updatedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
    };
}
