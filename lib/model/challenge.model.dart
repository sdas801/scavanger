class ChallengeModel {
  int id;
  String name;
  String description;
  String? imageurl;
  String? endtime;
  int status;
  String createdat;
  String? videofile;
  String otp;
  String qrcode;
  int? uploadedItems;
  int? totalItems;
  int? isprocessed;
  List<ChallengeItem>? items = [];

  ChallengeModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.imageurl,
      required this.endtime,
      required this.status,
      required this.createdat,
      required this.videofile,
      required this.otp,
      required this.qrcode,
      this.items,
      this.totalItems = 0,
      this.uploadedItems = 0,
      this.isprocessed = 0});

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      imageurl: json["imageurl"],
      endtime: json["endtime"],
      status: json["status"],
      createdat: json["createdat"],
      videofile: json["videofile"],
      otp: json["otp"],
      qrcode: json["qrcode"],
      totalItems: json["totalItems"] ?? 0,
      uploadedItems: json["uploadedItems"] ?? 0,
      isprocessed: json["isprocessed"] ?? 0,
      items: List<ChallengeItem>.from(
          json["items"].map((x) => ChallengeItem.fromJson(x))),
    );
  }
}

class ChallengeItem {
  int id;
  int itemid;
  int challengeid;
  String? itemname;
  String? type;
  String? description;
  String? imageurl;
  String? uploadedimg;
  dynamic snapshot;
  int? sequence;

  ChallengeItem(
      {required this.id,
      required this.itemid,
      required this.challengeid,
      required this.itemname,
      required this.type,
      required this.description,
      required this.imageurl,
      required this.uploadedimg,
      required this.snapshot,
      required this.sequence});

  factory ChallengeItem.fromJson(Map<String, dynamic> json) => ChallengeItem(
      id: json["id"],
      itemid: json["itemid"],
      challengeid: json["challengeid"],
      itemname: json["itemname"],
      type: json["type"],
      description: json["description"],
      imageurl: json["imageurl"],
      uploadedimg: json["uploadedimg"],
      snapshot: json["snapshot"],
      sequence: json["sequence"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "itemid": itemid,
        "challengeid": challengeid,
        "itemname": itemname,
        "type": type,
        "description": description,
        "imageurl": imageurl,
        "uploadedimg": uploadedimg,
        "snapshot": snapshot,
        'sequence': sequence
      };
}

class CreateChallengeResp {
  int id;

  CreateChallengeResp({
    required this.id,
  });

  factory CreateChallengeResp.fromJson(Map<String, dynamic> json) {
    return CreateChallengeResp(
      id: json["id"],
    );
  }
}

class CarouselModel {
  String imgUrl;
  String? link_url;

  CarouselModel({
    required this.imgUrl,
    required this.link_url,
  });

  factory CarouselModel.fromJson(Map<String, dynamic> json) {
    return CarouselModel(
      imgUrl: json["img_url"],
      link_url: json["link_url"],
    );
  }
}
