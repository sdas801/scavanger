class HuntItemList {
  final int id;
  final String title;
  final String description;
  final String game_img;
  final String videoFile;
  late bool checkItem;

  HuntItemList({
    required this.id,
    required this.title,
    required this.description,
    required this.game_img,
    required this.videoFile,
    this.checkItem = false,
  });

  // Parsing from JSON to create a HuntItemList object
  factory HuntItemList.fromJson(Map<String, dynamic> json) {
    return HuntItemList(
      id: json['id'],
      title: json["title"],
      description: json["description"],
      game_img: json["game_img"],
      videoFile: json["videoFile"],
    );
  }

  // Convert HuntItemList to JSON (optional if needed for requests)
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "game_img": game_img,
        "videoFile": videoFile,
      };
}

class ChallengeList {
  final int id;
  final String name;
  final String description;
  final String imageurl;
  final String? endtime;
  final String videofile;

  ChallengeList({
    required this.id,
    required this.name,
    required this.description,
    required this.imageurl,
    required this.endtime,
    required this.videofile,
  });

  // Parsing from JSON to create a HuntItemList object
  factory ChallengeList.fromJson(Map<String, dynamic> json) {
    return ChallengeList(
      id: json['id'],
      name: json["name"],
      description: json["description"],
      imageurl: json["imageurl"],
      endtime: json["endtime"],
      videofile: json["videofile"],
    );
  }

  // Convert HuntItemList to JSON (optional if needed for requests)
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "imageurl": imageurl,
        "endtime": endtime,
        "videofile": videofile,
      };
}
