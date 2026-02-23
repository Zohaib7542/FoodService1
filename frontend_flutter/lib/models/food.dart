class Food {
  String id;
  String name;
  double price;
  List<String> tags;
  bool favorite;
  double stars;
  String imageUrl;
  List<String> origins;
  String cookTime;

  Food({
    required this.id,
    required this.name,
    required this.price,
    this.tags = const [],
    this.favorite = false,
    required this.stars,
    required this.imageUrl,
    this.origins = const [],
    required this.cookTime,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      favorite: json['favorite'] ?? false,
      stars: (json['stars'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      origins: List<String>.from(json['origins'] ?? []),
      cookTime: json['cookTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'tags': tags,
      'favorite': favorite,
      'stars': stars,
      'imageUrl': imageUrl,
      'origins': origins,
      'cookTime': cookTime,
    };
  }
}
