class GameStep1 {
  int id;
  String gameId;
  String gameSessionId;
  String gameType;
  String? title;
  String? description;
  String? gameImg;

  GameStep1({
    required this.id,
    required this.gameId,
    required this.gameSessionId,
    required this.gameType,
    required this.title,
    required this.description,
    required this.gameImg,
  });

  factory GameStep1.fromJson(Map<String, dynamic> json) => GameStep1(
        id: json["id"],
        gameId: json["game_id"],
        gameSessionId: json["game_session_id"],
        gameType: json["game_type"],
        title: json["title"],
        description: json["description"],
        gameImg: json["game_img"],
      );
}

class GameStep2 {
  bool? isTimed;
  bool? isPrized;
  bool? isItemApproved;
  bool? isAllowToMsgOthers;
  int? maxTeam;

  GameStep2({
    required this.isTimed,
    required this.isPrized,
    required this.isItemApproved,
    required this.isAllowToMsgOthers,
    required this.maxTeam,
  });

  factory GameStep2.fromJson(Map<String, dynamic> json) => GameStep2(
        isTimed: json["is_timed"],
        isPrized: json["is_prized"],
        isItemApproved: json["is_item_approved"],
        isAllowToMsgOthers: json["is_allow_to_msg_others"],
        maxTeam: json["max_team"],
      );
}

class GameTimePage {
  DateTime? inTime;
  DateTime? outTime;
  bool? isPrized;
  String? gameDuration;

  GameTimePage({
    required this.inTime,
    required this.outTime,
    required this.gameDuration,
    required this.isPrized,
  });

  factory GameTimePage.fromJson(Map<String, dynamic> json) => GameTimePage(
        inTime: json["in_time"] != null ? DateTime.parse(json["in_time"]) : null,
        outTime: json["out_time"] != null? DateTime.parse(json["out_time"]):null,
        gameDuration: json["game_duration"],
        isPrized: json["is_prized"],
      );
}

class GamePrizePage{
  bool? isTimed;
  bool? isPrized;
  List<Prize> prizes;

  GamePrizePage({
    required this.isTimed,
    required this.prizes,
    required this.isPrized,
  });

  factory GamePrizePage.fromJson(Map<String, dynamic> json) => GamePrizePage(
    isTimed: json["is_timed"],
    isPrized: json["is_prized"],
    prizes: List<Prize>.from(json["prizes"].map((x) => Prize.fromJson(x))),
  );
}

class Prize {
    int id;
    int gameId;
    String gameUniqueId;
    String? firstDesc;
    String? firstPrizeImgUrl;
    String? secondDesc;
    String? secondPrizeImgUrl;
    String? thirdDesc;
    String? thirdPrizeImgUrl;

    Prize({
        required this.id,
        required this.gameId,
        required this.gameUniqueId,
        required this.firstDesc,
        required this.firstPrizeImgUrl,
        required this.secondDesc,
        required this.secondPrizeImgUrl,
        required this.thirdDesc,
        required this.thirdPrizeImgUrl,
    });

    factory Prize.fromJson(Map<String, dynamic> json) => Prize(
        id: json["id"],
        gameId: json["game_id"],
        gameUniqueId: json["game_unique_id"],
        firstDesc: json["first_desc"],
        firstPrizeImgUrl: json["first_prize_img_url"],
        secondDesc: json["second_desc"],
        secondPrizeImgUrl: json["second_prize_img_url"],
        thirdDesc: json["third_desc"],
        thirdPrizeImgUrl: json["third_prize_img_url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "game_id": gameId,
        "game_unique_id": gameUniqueId,
        "first_desc": firstDesc,
        "first_prize_img_url": firstPrizeImgUrl,
        "second_desc": secondDesc,
        "second_prize_img_url": secondPrizeImgUrl,
        "third_desc": thirdDesc,
        "third_prize_img_url": thirdPrizeImgUrl,
    };
}

class GameRule {
  String? rule;

  GameRule({
    required this.rule,
  });

  factory GameRule.fromJson(Map<String, dynamic> json) => GameRule(
    rule: json["game_rules"],
  );
}

