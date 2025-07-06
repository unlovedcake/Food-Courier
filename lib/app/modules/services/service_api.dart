class ServiceApi {
  // Factory constructor
  factory ServiceApi() => _instance;

  // Private constructor
  ServiceApi._internal();
  // Singleton instance
  static final ServiceApi _instance = ServiceApi._internal();

  //FlutterSecureStorage storage = const FlutterSecureStorage();

  final String _baseUrl = '';
  final String _token = '';

  Future<void> setServiceApi(final Map<String, dynamic> json) async {
    // await storage.write(key: 'apiBaseUrl', value: json['apiBaseUrl'] ?? '');

    // _baseUrl = await storage.read(key: 'apiBaseUrl') ?? '';
    // _token = await storage.read(key: 'token') ?? '';
  }

  String get baseUrl => _baseUrl;
  String get token => _token;
}
