// To parse this JSON data, do
//
//     final createTeamResponse = createTeamResponseFromJson(jsonString);

import 'dart:convert';

CreateTeamResponse createTeamResponseFromJson(String str) => CreateTeamResponse.fromJson(json.decode(str));

String createTeamResponseToJson(CreateTeamResponse data) => json.encode(data.toJson());

class CreateTeamResponse {
    String status;
    bool success;
    String mesasge;
    String url;
    Result result;

    CreateTeamResponse({
        required this.status,
        required this.success,
        required this.mesasge,
        required this.url,
        required this.result,
    });

    factory CreateTeamResponse.fromJson(Map<String, dynamic> json) => CreateTeamResponse(
        status: json["status"],
        success: json["success"],
        mesasge: json["mesasge"],
        url: json["url"],
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "mesasge": mesasge,
        "url": url,
        "result": result.toJson(),
    };
}

class Result {
    Participant participant;
    Team team;

    Result({
        required this.participant,
        required this.team,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        participant: Participant.fromJson(json["participant"]),
        team: Team.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "participant": participant.toJson(),
        "team": team.toJson(),
    };
}

class Participant {
    int id;
    String name;
    String email;
    String phone;
    String userImg;
    DateTime updatedAt;
    DateTime createdAt;

    Participant({
        required this.id,
        required this.name,
        required this.email,
        required this.phone,
        required this.userImg,
        required this.updatedAt,
        required this.createdAt,
    });

    factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        userImg: json["user_img"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        createdAt: DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "user_img": userImg,
        "updatedAt": updatedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
    };
}

class Team {
    int id;
    String teamId;
    int participantId;
    DateTime updatedAt;
    DateTime createdAt;

    Team({
        required this.id,
        required this.teamId,
        required this.participantId,
        required this.updatedAt,
        required this.createdAt,
    });

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json["id"],
        teamId: json["team_id"],
        participantId: json["participant_id"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        createdAt: DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "team_id": teamId,
        "participant_id": participantId,
        "updatedAt": updatedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
    };
}
