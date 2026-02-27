class User {
  String id;
  String email;
  String name;
  String address;
  String token;
  bool isAdmin;
  bool isRestaurantOwner;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.address,
    required this.token,
    required this.isAdmin,
    required this.isRestaurantOwner,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      token: json['token'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      isRestaurantOwner: json['isRestaurantOwner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'address': address,
      'token': token,
      'isAdmin': isAdmin,
      'isRestaurantOwner': isRestaurantOwner,
    };
  }
}
