// To parse this JSON data, do
//
//     final gameStatusResponse = gameStatusResponseFromJson(jsonString);

import 'dart:convert';

GameStatusResponse gameStatusResponseFromJson(String str) => GameStatusResponse.fromJson(json.decode(str));

String gameStatusResponseToJson(GameStatusResponse data) => json.encode(data.toJson());

class GameStatusResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    GameStatus result;

    GameStatusResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory GameStatusResponse.fromJson(Map<String, dynamic> json) => GameStatusResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: GameStatus.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": result.toJson(),
    };
}

class GameStatus {
    int id;
    String gameId;
    String gameSessionId;
    String gameType;
    String title;
    String description;
    bool? isTimed;
    bool? isPrized;
    bool? isItemApproved;
    bool? isAllowToMsgOthers;
    int? maxTeam;
    DateTime? inTime;
    DateTime? outTime;
    String? gameDuration;
    String otp;
    String qrCode;
    String gameRules;
    String status;
    int hostBy;

    GameStatus({
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
    });

    factory GameStatus.fromJson(Map<String, dynamic> json) => GameStatus(
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
        inTime: json["in_time"] != null ? DateTime.parse(json["in_time"]) : null,
        outTime: json["out_time"] != null ? DateTime.parse(json["out_time"]) : null,
        gameDuration: json["game_duration"],
        otp: json["otp"],
        qrCode: json["qr_code"],
        gameRules: json["game_rules"],
        status: json["status"],
        hostBy: json["host_by"],
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
        "in_time": inTime?.toIso8601String(),
        "out_time": outTime?.toIso8601String(),
        "game_duration": gameDuration,
        "otp": otp,
        "qr_code": qrCode,
        "game_rules": gameRules,
        "status": status,
        "host_by": hostBy,
    };
}
