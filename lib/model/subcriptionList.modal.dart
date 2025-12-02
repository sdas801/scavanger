class SubcriptionList {
  final int id;
  final String name;
  final String? description;
  final dynamic maxHunts;
  final dynamic maxChallenge;
  final dynamic priceMonthly;
  final dynamic priceAnnually;
  late bool ischeckItem;
  late String? planType;
  dynamic maxHuntItems;
  dynamic maxChallengeItems;
  dynamic maxCreatedItems;
  dynamic maxPurchasedItems;
  dynamic maxHuntTeams;
  dynamic videoAvailable;
  int isRelaunch;

  SubcriptionList(
      {required this.id,
      required this.name,
      required this.description,
      required this.maxHunts,
      required this.maxChallenge,
      required this.priceMonthly,
      required this.priceAnnually,
      this.ischeckItem = false,
      this.planType = "",
      required this.maxHuntItems,
      required this.maxChallengeItems,
      required this.maxCreatedItems,
      required this.maxPurchasedItems,
      required this.maxHuntTeams,
      required this.videoAvailable,
      required this.isRelaunch});

  // Parsing from JSON to create a SubcriptionList object
  factory SubcriptionList.fromJson(Map<String, dynamic> json) {
    return SubcriptionList(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      maxHunts: json["max_hunts"],
      maxChallenge: json["max_challenges"],
      priceMonthly: json["price_monthly"],
      priceAnnually: json["price_annually"],
      ischeckItem: false,
      planType: "",
      maxHuntItems: json["max_hunt_items"],
      maxChallengeItems: json["max_challenge_items"],
      maxCreatedItems: json["max_created_items"],
      maxPurchasedItems: json["max_purchased_items"],
      maxHuntTeams: json["max_hunt_teams"],
      videoAvailable: json["video_available"],
      isRelaunch: json["is_relaunch"],
    );
  }

  // Convert SubcriptionList to JSON (optional if needed for requests)
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "max_hunts": maxHunts,
        "max_challenges": maxChallenge,
        "price_monthly": priceMonthly,
        "price_annually": priceAnnually,
        "ischeckItem": false,
        "planType": "",
        "max_hunt_items": maxHuntItems,
        "max_challenge_items": maxChallengeItems,
        "max_created_items": maxCreatedItems,
        "max_purchased_items": maxPurchasedItems,
        "max_hunt_teams": maxHuntTeams,
        "video_available": videoAvailable,
        "is_relaunch": isRelaunch,
      };
}
