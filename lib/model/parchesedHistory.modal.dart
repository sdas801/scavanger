class historyItem {
  String subscription_name;
  String start_date;
  String end_date;
  int is_expire;
  String plan_type;
  String orderId;
  String status;
  String createdAt;
  dynamic amount;

  historyItem(
      {required this.subscription_name,
      required this.start_date,
      required this.end_date,
      required this.is_expire,
      required this.plan_type,
      required this.orderId,
      required this.status,
      required this.createdAt,
      required this.amount});

  factory historyItem.fromJson(Map<String, dynamic> json) => historyItem(
      subscription_name: json["subscription_name"],
      start_date: json["start_date"],
      end_date: json["end_date"],
      is_expire: json["is_expire"],
      plan_type: json["plan_type"],
      orderId: json["orderId"],
      status: json["status"],
      createdAt: json["createdAt"],
      amount: json["amount"]);

  Map<String, dynamic> toJson() => {
        "subscription_name": subscription_name,
        "start_date": start_date,
        "end_date": end_date,
        "is_expire": is_expire,
        "plan_type": plan_type,
        "orderId": orderId,
        "status": status,
        "createdAt": createdAt,
        "amount": amount
      };
}
