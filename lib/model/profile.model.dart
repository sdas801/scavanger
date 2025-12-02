class UserModel {
  int id;
  String name;
  String uniqueId;
  String username;
  String email;
  String phone;
  String? city;
  String? state;
  int? stateId;
  String? country;
  int? countryId;
  String? address;
  String? pincode;
  String? dob;
  String? profileImage;

  UserModel(
      {required this.id,
      required this.name,
      required this.uniqueId,
      required this.username,
      required this.email,
      required this.phone,
      this.city,
      this.state,
      this.stateId,
      this.country,
      this.countryId,
      this.address,
      this.pincode,
      this.dob,
      this.profileImage
      });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      uniqueId: json['unique_id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      city: json['city'],
      state: json['state_name'],
      stateId: json['state_id'],
      country: json['country_name'],
      countryId: json['country_id'],
      address: json['address'],
      pincode: json['pincode'],
      dob: json['dob'],
      profileImage: json['user_img']
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uniqueId': uniqueId,
      'username': username,
      'email': email,
      'phone': phone,
      'city': city,
      'state': state,
      'stateId': stateId,
      'country': country,
      'countryId': countryId,
      'address': address,
      'pincode': pincode,
      'dob': dob,
      'profileImage': profileImage
    };
  }
}