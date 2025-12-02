class CouponList {
  int discount_id;
  String discount_code;
  String discount_name;
  int discount_amount;
  String discount_type;
  String status;

  CouponList({
    required this.discount_id,
    required this.discount_code,
    required this.discount_name,
    required this.discount_amount,
    required this.discount_type,
    required this.status,
  });

  factory CouponList.fromJson(Map<String, dynamic> json) => CouponList(
        discount_id: json["discount_id"],
        discount_code: json["discount_code"],
        discount_name: json["discount_name"],
        discount_amount: json["discount_amount"],
        discount_type: json["discount_type"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "discount_id": discount_id,
        "discount_code": discount_code,
        "discount_name": discount_name,
        "discount_amount": discount_amount,
        "discount_type": discount_type,
        "status": status,
      };
}

class ApplyRespo {
  int discount_id;
  String discount_code;
  String discount_name;
  int discount_amount;
  String discount_type;
  String status;

  ApplyRespo({
    required this.discount_id,
    required this.discount_code,
    required this.discount_name,
    required this.discount_amount,
    required this.discount_type,
    required this.status,
  });
  factory ApplyRespo.fromJson(Map<String, dynamic> json) {
    return ApplyRespo(
      discount_id: json["discount_id"],
      discount_code: json["discount_code"],
      discount_name: json["discount_name"],
      discount_amount: json["discount_amount"],
      discount_type: json["discount_type"],
      status: json["status"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "discount_id": discount_id,
      "discount_code": discount_code,
      "discount_name": discount_name,
      "discount_amount": discount_amount,
      "discount_type": discount_type,
      "status": status,
    };
  }
}
