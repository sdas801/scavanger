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
  List<ItemList> result;

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
        result: List<ItemList>.from(
            json["result"].map((x) => ItemList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class ItemList {
  int id;
  String itemname;
  String? description;
  String imageurl;
  late bool ischeckItem;

  ItemList({
    required this.id,
    required this.itemname,
    required this.description,
    required this.imageurl,
    this.ischeckItem = false,
  });

  factory ItemList.fromJson(Map<String, dynamic> json) => ItemList(
        id: json["id"],
        itemname: json["itemname"],
        description: json["description"],
        imageurl: json["imageurl"],
        ischeckItem: false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "itemname": itemname,
        "description": description,
        "imageurl": imageurl,
        "ischeckItem": true,
      };
}
