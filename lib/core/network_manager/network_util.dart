import 'package:http_interceptor/http_interceptor.dart';
import 'package:task_manager_app/core/interceptors/api_interceptor.dart';

class NetworkUtil {
  factory NetworkUtil() => _instance;

  NetworkUtil._();

  static final NetworkUtil _instance = NetworkUtil._();

  final _client = InterceptedHttp.build(
    interceptors: [
      ApiInterceptor(),
    ],
  );

  InterceptedHttp get client => _client;
}
