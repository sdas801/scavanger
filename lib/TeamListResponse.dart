// To parse this JSON data, do
//
//     final teamListResponse = teamListResponseFromJson(jsonString);

import 'dart:convert';

TeamListResponse teamListResponseFromJson(String str) => TeamListResponse.fromJson(json.decode(str));

String teamListResponseToJson(TeamListResponse data) => json.encode(data.toJson());

class TeamListResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    List<Result> result;

    TeamListResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory TeamListResponse.fromJson(Map<String, dynamic> json) => TeamListResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
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
    int gameId;
    String gameUniqueId;
    String status;
    String teamId;
    Player player;

    Result({
        required this.id,
        required this.gameId,
        required this.gameUniqueId,
        required this.status,
        required this.teamId,
        required this.player,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        gameId: json["game_id"],
        gameUniqueId: json["game_unique_id"],
        status: json["status"],
        teamId: json["team_id"],
        player: Player.fromJson(json["player"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_unique_id": gameUniqueId,
        "status": status,
        "team_id": teamId,
        "player": player.toJson(),
    };
}

class Player {
    int id;
    String name;
    String username;
    String uniqueId;
    String email;
    String phone;
    dynamic userImg;

    Player({
        required this.id,
        required this.name,
        required this.username,
        required this.uniqueId,
        required this.email,
        required this.phone,
        required this.userImg,
    });

    factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        uniqueId: json["unique_id"],
        email: json["email"],
        phone: json["phone"],
        userImg: json["user_img"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "unique_id": uniqueId,
        "email": email,
        "phone": phone,
        "user_img": userImg,
    };
}
