import 'package:http/http.dart' as http;

class NetworkUtil {
  factory NetworkUtil() => _instance;

  NetworkUtil._();

  static final NetworkUtil _instance = NetworkUtil._();

  final http.Client _client = http.Client();

  http.Client get client => _client;
}
