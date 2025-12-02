// To parse this JSON data, do
//
//     final joinGameResponse = joinGameResponseFromJson(jsonString);

import 'dart:convert';

JoinGameResponse joinGameResponseFromJson(String str) => JoinGameResponse.fromJson(json.decode(str));

String joinGameResponseToJson(JoinGameResponse data) => json.encode(data.toJson());

class JoinGameResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    JoinGameDtl result;

    JoinGameResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory JoinGameResponse.fromJson(Map<String, dynamic> json) => JoinGameResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: JoinGameDtl.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": result.toJson(),
    };
}

class JoinGameDtl {
    GamePlay gamePlay;
    List<PalyItem> palyItems;

    JoinGameDtl({
        required this.gamePlay,
        required this.palyItems,
    });

    factory JoinGameDtl.fromJson(Map<String, dynamic> json) => JoinGameDtl(
        gamePlay: GamePlay.fromJson(json["gamePlay"]),
        palyItems: List<PalyItem>.from(json["palyItems"].map((x) => PalyItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "gamePlay": gamePlay.toJson(),
        "palyItems": List<dynamic>.from(palyItems.map((x) => x.toJson())),
    };
}

class GamePlay {
    String status;
    int gainPoint;
    int id;
    int gameId;
    String gameUniqueId;
    int userId;
    String userUniqueId;
    int totalPoint;
    String teamId;
    DateTime updatedAt;
    DateTime createdAt;

    GamePlay({
        required this.status,
        required this.gainPoint,
        required this.id,
        required this.gameId,
        required this.gameUniqueId,
        required this.userId,
        required this.userUniqueId,
        required this.totalPoint,
        required this.teamId,
        required this.updatedAt,
        required this.createdAt,
    });

    factory GamePlay.fromJson(Map<String, dynamic> json) => GamePlay(
        status: json["status"],
        gainPoint: json["gain_point"],
        id: json["id"],
        gameId: json["game_id"],
        gameUniqueId: json["game_unique_id"],
        userId: json["user_id"],
        userUniqueId: json["user_unique_id"],
        totalPoint: json["total_point"],
        teamId: json["team_id"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        createdAt: DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "gain_point": gainPoint,
        "id": id,
        "game_id": gameId,
        "game_unique_id": gameUniqueId,
        "user_id": userId,
        "user_unique_id": userUniqueId,
        "total_point": totalPoint,
        "team_id": teamId,
        "updatedAt": updatedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
    };
}

class PalyItem {
    dynamic itemImgUrl;
    int gainPoint;
    int id;
    int itemId;
    int itemPoint;
    String status;
    String teamId;
    DateTime createdAt;
    DateTime updatedAt;

    PalyItem({
        required this.itemImgUrl,
        required this.gainPoint,
        required this.id,
        required this.itemId,
        required this.itemPoint,
        required this.status,
        required this.teamId,
        required this.createdAt,
        required this.updatedAt,
    });

    factory PalyItem.fromJson(Map<String, dynamic> json) => PalyItem(
        itemImgUrl: json["item_img_url"],
        gainPoint: json["gain_point"],
        id: json["id"],
        itemId: json["item_id"],
        itemPoint: json["item_point"],
        status: json["status"],
        teamId: json["team_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "item_img_url": itemImgUrl,
        "gain_point": gainPoint,
        "id": id,
        "item_id": itemId,
        "item_point": itemPoint,
        "status": status,
        "team_id": teamId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}
