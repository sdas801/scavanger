class Country{
  String name;
  int id;
  int? phoneCode;
  Country({required this.name, required this.id, this.phoneCode});
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      id: json['id'],
      phoneCode: json['phoneCode'],
    );
  }
}

class CState{
  String name;
  int id;
  CState({required this.name, required this.id});
  factory CState.fromJson(Map<String, dynamic> json) {
    return CState(
      name: json['name'],
      id: json['id'],
    );
  }
}