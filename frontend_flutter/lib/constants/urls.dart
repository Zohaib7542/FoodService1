class AppUrls {
  // Use 10.0.2.2 for Android emulator pointing to localhost, or actual IP for physical devices
  // Since we run on flutter run -d chrome, localhost is fine. If deploying, change this.
  static const String baseUrl = 'http://localhost:5002';

  static const String foodsUrl = '$baseUrl/api/foods';
  static const String foodsTagsUrl = '$foodsUrl/tags';
  static const String foodsBySearchUrl = '$foodsUrl/search/';
  static const String foodsByTagUrl = '$foodsUrl/tag/';
  static const String foodByIdUrl = '$foodsUrl/';
  static const String foodsByRestaurantUrl = '$foodsUrl/restaurant/';

  static const String restaurantsUrl = '$baseUrl/api/restaurants';

  static const String userLoginUrl = '$baseUrl/api/users/login';
  static const String userRegisterUrl = '$baseUrl/api/users/register';
  static const String userRedeemPointsUrl = '$baseUrl/api/users/redeem-points';
  static const String userMeUrl = '$baseUrl/api/users/me/';

  static const String ordersUrl = '$baseUrl/api/orders';
  static const String orderCreateUrl = '$ordersUrl/create';
  static const String orderCreateRazorpayUrl = '$ordersUrl/create-razorpay-order';
  static const String orderVerifyRazorpayUrl = '$ordersUrl/verify-razorpay-signature';
  static const String orderNewForCurrentUserUrl = '$ordersUrl/newOrderForCurrentUser';
  static const String orderPayUrl = '$ordersUrl/pay';
  static const String orderTrackUrl = '$ordersUrl/track/';
}
