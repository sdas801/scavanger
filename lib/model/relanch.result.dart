class RelanchModel {
  int id;
  String? game_session_id;

  RelanchModel({
    required this.id,
    required this.game_session_id,
  });
  factory RelanchModel.fromJson(Map<String, dynamic> json) {
    return RelanchModel(
      id: json['id'],
      game_session_id: json['game_session_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_session_id': game_session_id,
    };
  }
}
