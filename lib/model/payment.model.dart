class PaymentIntentModel {
  String clientSecret;
  int paymentId;

  PaymentIntentModel({required this.clientSecret, required this.paymentId});

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentModel(
      clientSecret: json['clientSecret'],
      paymentId: json['paymentId'],
    );
  }
}