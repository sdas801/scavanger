// To parse this JSON data, do
//
//     final gameTeamListResponse = gameTeamListResponseFromJson(jsonString);

import 'dart:convert';

GameTeamListResponse gameTeamListResponseFromJson(String str) =>
    GameTeamListResponse.fromJson(json.decode(str));

String gameTeamListResponseToJson(GameTeamListResponse data) =>
    json.encode(data.toJson());

class GameTeamListResponse {
  String status;
  bool success;
  String mesasge;
  String url;
  List<ResultGameteamItem> result;

  GameTeamListResponse({
    required this.status,
    required this.success,
    required this.mesasge,
    required this.url,
    required this.result,
  });

  factory GameTeamListResponse.fromJson(Map<String, dynamic> json) =>
      GameTeamListResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: List<ResultGameteamItem>.from(
            json["result"].map((x) => ResultGameteamItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class ResultGameteamItem {
  String teamId;
  String status;
  String? teamname;
  String? teamimg;
  Player player;
  List<PlayItem> playItems;
  int? issubmitted;

  ResultGameteamItem({
    required this.teamId,
    required this.status,
    required this.teamname,
    required this.teamimg,
    required this.player,
    required this.playItems,
    this.issubmitted,
  });

  factory ResultGameteamItem.fromJson(Map<String, dynamic> json) =>
      ResultGameteamItem(
        teamId: json["team_id"],
        status: json["status"],
        teamname: json["teamname"],
        teamimg: json["teamimg"],
        player: Player.fromJson(json["player"]),
        playItems: List<PlayItem>.from(
            json["playItems"].map((x) => PlayItem.fromJson(x))),
        issubmitted: json["issubmitted"],
      );

  Map<String, dynamic> toJson() => {
        "team_id": teamId,
        "status": status,
        "teamname": teamname,
        "teamimg": teamimg,
        "player": player.toJson(),
        "playItems": List<dynamic>.from(playItems.map((x) => x.toJson())),
        "issubmitted": issubmitted,
      };
}

class PlayItem {
  int id;
  String? itemImgUrl;
  String status;
  String? type;
  int itemid;
  String name;
  dynamic snapshot;
  String? updatedAt;
  String? baseimage;
  // Item item;

  PlayItem({
    required this.id,
    required this.itemImgUrl,
    required this.status,
    required this.type,
    required this.itemid,
    required this.name,
    required this.snapshot,
    this.updatedAt,
    this.baseimage,
    // required this.item,
  });

  factory PlayItem.fromJson(Map<String, dynamic> json) => PlayItem(
        id: json["id"],
        itemImgUrl: json["item_img_url"],
        status: json["status"],
        type: json["type"],
        itemid: json["itemid"],
        name: json["name"],
        snapshot: json["snapshot"],
        updatedAt: json["updatedAt"],
        baseimage: json["baseimage"],

        // item: Item.fromJson(json["item"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "item_img_url": itemImgUrl,
        "status": status,
        "type": type,
        "itemid": itemid,
        "name": name,
        "snapshot": snapshot,
        "updatedAt": updatedAt,
        "baseimage": baseimage,
        // "item": item.toJson(),
      };
}

class Item {
  int id;
  String name;

  Item({
    required this.id,
    required this.name,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class Player {
  int id;
  String name;
  String email;

  Player({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json["id"],
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}
