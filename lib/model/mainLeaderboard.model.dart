class MainLeaderboardModel {
  int id;
  String gameId;
  String gameType;
  String? gameImg;
  String title;
  String description;
  String status;
  List<TopPlayer> topPlayers;
  Prizes? prizes;

  MainLeaderboardModel(
      {required this.id,
      required this.gameId,
      required this.gameType,
      required this.gameImg,
      required this.title,
      required this.description,
      required this.status,
      required this.topPlayers,
      required this.prizes});
  factory MainLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return MainLeaderboardModel(
      id: json['id'],
      gameId: json['game_id'],
      gameType: json['game_type'],
      gameImg: json['game_img'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      topPlayers: List<TopPlayer>.from(json["topPlayers"].map((x) => TopPlayer.fromJson(x))),
      prizes: Prizes.fromJson(json["prizes"]),
    );
  }
}

class TopPlayer {
  int id;
  String userName;
  String? userImg;
  int position;

  TopPlayer(
      {required this.id,
      required this.userName,
      required this.userImg,
      required this.position});
  factory TopPlayer.fromJson(Map<String, dynamic> json) {
    return TopPlayer(
      id: json['id'],
      userName: json['user_name'],
      userImg: json['user_img'],
      position: json['position'],
    );
  }
}

class Prizes {
  String? firstDesc;
  String? secondDesc;
  String? thirdDesc;
  String? firstImg;
  String? secondImg;
  String? thirdImg;

  Prizes(
      {required this.firstDesc,
      required this.secondDesc,
      required this.thirdDesc,
      required this.firstImg,
      required this.secondImg,
      required this.thirdImg});
  factory Prizes.fromJson(Map<String, dynamic> json) {
    return Prizes(
      firstDesc: json['first_desc'],
      secondDesc: json['second_desc'],
      thirdDesc: json['third_desc'],
      firstImg: json['first_prize_img_url'],
      secondImg: json['second_prize_img_url'],
      thirdImg: json['third_prize_img_url']);
  }
}