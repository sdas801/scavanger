class LeaderBoardListModel {
  final List<LeaderBoardModel> leaderBoardModelList;

  LeaderBoardListModel({
    required this.leaderBoardModelList,
  });

  factory LeaderBoardListModel.fromJson(List<dynamic> json) =>
      LeaderBoardListModel(
        leaderBoardModelList: List<LeaderBoardModel>.from(
            json.map((x) => LeaderBoardModel.fromJson(x))),
      );
}

class LeaderBoardModel {
  String teamId;
  int userId;
  String userName;
  int totalItems;
  int notAttemptedItems;
  int acceptedItems;
  int rejectItems;
  String? userImg;

  LeaderBoardModel({
    required this.teamId,
    required this.userId,
    required this.userName,
    required this.totalItems,
    required this.notAttemptedItems,
    required this.acceptedItems,
    required this.rejectItems,
    required this.userImg,
  });
  factory LeaderBoardModel.fromJson(Map<String, dynamic> json) {
    return LeaderBoardModel(
        teamId: json['teamId'],
        userId: json['userId'],
        userName: json['userName'],
        totalItems: json['totalItems'],
        notAttemptedItems: json['notAttemptedItems'],
        acceptedItems: json['acceptedItems'],
        rejectItems: json['rejectItems'],
        userImg: json['userImg']
        );
  }
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'userId': userId,
      'userName': userName,
      'totalItems': totalItems,
      'notAttemptedItems': notAttemptedItems,
      'acceptedItems': acceptedItems,
      'rejectItems': rejectItems,
      'userImg': userImg
    };
  }
}
