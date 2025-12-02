// To parse this JSON data, do
//
//     final myGameItemListResponse = myGameItemListResponseFromJson(jsonString);

import 'dart:convert';

MyGameItemListResponse myGameItemListResponseFromJson(String str) =>
    MyGameItemListResponse.fromJson(json.decode(str));

String myGameItemListResponseToJson(MyGameItemListResponse data) =>
    json.encode(data.toJson());

class MyGameItemListResponse {
  String status;
  bool success;
  String mesasge;
  String url;
  ResultData result;

  MyGameItemListResponse({
    required this.status,
    required this.success,
    required this.mesasge,
    required this.url,
    required this.result,
  });

  factory MyGameItemListResponse.fromJson(Map<String, dynamic> json) =>
      MyGameItemListResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: ResultData.fromJson(json["result"]),
        // result: List<ResultGameTeam>.from(json["result"].map((x) => ResultGameTeam.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": result.toJson(),

        // "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class TeamDtl {
  final String teamname;

  TeamDtl({
    required this.teamname,
  });

  factory TeamDtl.fromJson(Map<String, dynamic> json) => TeamDtl(
        teamname: json["teamname"],
      );

  Map<String, dynamic> toJson() => {
        "teamname": teamname,
      };
}

class ResultData {
  List<ResultGameTeam> items;
  bool isEnd;
  TeamDtl teamDtl;

  ResultData({
    required this.items,
    required this.isEnd,
    required this.teamDtl,
  });

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
        items: List<ResultGameTeam>.from(
            json["items"].map((x) => ResultGameTeam.fromJson(x))),
        isEnd: json["isEnd"],
        teamDtl: TeamDtl.fromJson(json["teamDtl"]),
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "isEnd": isEnd,
        "teamDtl": teamDtl.toJson(),
      };
}

class ResultGameTeam {
  int id;
  dynamic itemImgUrl;
  String status;
  Item item;
  bool? isUploading;
  dynamic snapshot;
  int sequence;

  ResultGameTeam({
    required this.id,
    required this.itemImgUrl,
    required this.status,
    required this.item,
    this.isUploading = false,
    required this.snapshot,
    required this.sequence,
  });

  factory ResultGameTeam.fromJson(Map<String, dynamic> json) => ResultGameTeam(
      id: json["id"],
      itemImgUrl: json["item_img_url"],
      status: json["status"],
      item: Item.fromJson(json["item"]),
      isUploading: false,
      snapshot: json["snapshot"],
      sequence: json["sequence"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "item_img_url": itemImgUrl,
        "status": status,
        "item": item.toJson(),
        "isUploading": false,
        "snapshot": snapshot,
        "sequence": sequence
      };
}

class Item {
  int id;
  String name;
  String description;
  String imgUrl;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.imgUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        imgUrl: json["img_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "img_url": imgUrl,
      };
}
