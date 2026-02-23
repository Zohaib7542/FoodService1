import 'cart_item.dart';

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);

  factory LatLng.fromJson(Map<String, dynamic> json) {
    if (json['lat'] != null && json['lng'] != null) {
      return LatLng(json['lat'], json['lng']);
    }
    // Handle array format [lat, lng]
    if (json.containsKey('latitude') && json.containsKey('longitude')) {
       return LatLng(json['latitude'], json['longitude']);
    }
    return LatLng(0, 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
    };
  }
}

class Order {
  int id;
  List<CartItem> items;
  double totalPrice;
  String name;
  String address;
  LatLng? addressLatLng;
  String paymentId;
  String createdAt;
  String status;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.name,
    required this.address,
    this.addressLatLng,
    required this.paymentId,
    required this.createdAt,
    required this.status,
  });
}
