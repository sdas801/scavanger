class MyPlayedGameListModel {
  final List<MyPlayedGameModel> myPlayedGameList;

  MyPlayedGameListModel({
    required this.myPlayedGameList,
  });

  factory MyPlayedGameListModel.fromJson(List<dynamic> json) => MyPlayedGameListModel(
    myPlayedGameList: List<MyPlayedGameModel>.from(json.map((x) => MyPlayedGameModel.fromJson(x))),
  );
}


class MyPlayedGameModel {
  int id;
  String gameId;
  String gameType;
  String? gameImg;
  String title;
  String description;
  String status;
  String teamId;

  MyPlayedGameModel(
      {required this.id,
      required this.gameId,
      required this.gameType,
      required this.gameImg,
      required this.title,
      required this.description,
      required this.status,
      required this.teamId
      });
  factory MyPlayedGameModel.fromJson(Map<String, dynamic> json) {
    return MyPlayedGameModel(
      id: json['id'],
      gameId: json['game_id'],
      gameType: json['game_type'],
      gameImg: json['game_img'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      teamId: json['team_id'],
    );
  }
}