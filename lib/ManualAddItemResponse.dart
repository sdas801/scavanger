// To parse this JSON data, do
//
//     final manualAddItemResponse = manualAddItemResponseFromJson(jsonString);

import 'dart:convert';

ManualAddItemResponse manualAddItemResponseFromJson(String str) => ManualAddItemResponse.fromJson(json.decode(str));

String manualAddItemResponseToJson(ManualAddItemResponse data) => json.encode(data.toJson());

class ManualAddItemResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    List<Result> result;

    ManualAddItemResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory ManualAddItemResponse.fromJson(Map<String, dynamic> json) => ManualAddItemResponse(
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
    String name;
    String description;
    int point;
    String imgUrl;
    DateTime createdAt;
    DateTime updatedAt;

    Result({
        required this.id,
        required this.gameId,
        required this.gameUniqueId,
        required this.name,
        required this.description,
        required this.point,
        required this.imgUrl,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        gameId: json["game_id"],
        gameUniqueId: json["game_unique_id"],
        name: json["name"],
        description: json["description"],
        point: json["point"],
        imgUrl: json["img_url"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_unique_id": gameUniqueId,
        "name": name,
        "description": description,
        "point": point,
        "img_url": imgUrl,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}
