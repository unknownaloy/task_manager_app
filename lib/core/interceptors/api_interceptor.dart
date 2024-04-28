import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';

class ApiInterceptor implements InterceptorContract {
  final baseUrl = "https://dummyjson.com";

  @override
  Future<BaseRequest> interceptRequest({
    required BaseRequest request,
  }) async {

    if (request.method.toUpperCase() == "POST") {
      debugPrint("IS POST REQUEST");
      request.headers["Content-type"] = "application/json";
    }

    // Check if the request URL already contains the base URL
    if (!request.url.toString().startsWith(baseUrl)) {
      // Create a new URL by concatenating the base URL with the current request URL
      final updatedUrl = Uri.parse(baseUrl + request.url.toString());

      // Create a new request with the updated URL
      final updatedRequest = request.copyWith(url: updatedUrl);

      debugPrint("updatedRequest - ${updatedRequest.url}");

      return updatedRequest;
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {

    debugPrint("ApiInterceptor ------------START----------->");
    debugPrint("\nApiInterceptor - METHOD -- ${response.request?.method.toUpperCase()}");
    debugPrint("\nApiInterceptor - URL -- ${response.request?.url}");
    debugPrint("\nApiInterceptor - STATUS_CODE -- ${response.statusCode}");
    if (response is Response) {
      debugPrint("\nApiInterceptor - RESPONSE -- ${response.body}");

    }
    debugPrint("ApiInterceptor ------------END----------->");


    return response;
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;
}
