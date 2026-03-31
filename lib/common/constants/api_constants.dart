class ApiConstants {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
  static const String apiToken = String.fromEnvironment('API_TOKEN', defaultValue: '');
  static const String authLogin = '/api/auth/login';
  static const String products = '/api/products';
  static const String wishlist = '/api/wishlist';
}
