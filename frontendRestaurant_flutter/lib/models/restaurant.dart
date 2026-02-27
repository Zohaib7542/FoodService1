class Restaurant {
  String id;
  String name;
  String address;
  String imageUrl;
  String ownerId;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.ownerId,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ownerId: json['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
    };
  }
}
