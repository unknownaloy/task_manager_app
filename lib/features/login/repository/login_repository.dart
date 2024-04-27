import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:task_manager_app/core/data/models/user/user.dart';
import 'package:task_manager_app/core/network_manager/network_util.dart';
import 'package:task_manager_app/core/utils/failure.dart';
import 'package:task_manager_app/core/utils/typedefs.dart';
import 'package:task_manager_app/features/login/data/login_dto.dart';

class LoginRepository {
  factory LoginRepository() => _instance;

  LoginRepository._internal(this._network);

  static final LoginRepository _instance =
      LoginRepository._internal(NetworkUtil());

  final NetworkUtil _network;

  Future<User> login(LoginDto params) async {
    try {
      final url = Uri.parse("/auth/login");

      final response = await _network.client.post(
        url,
        body: params.toJson(),
      );

      final json = jsonDecode(response.body) as JSON;

      if (response.statusCode == 400) {
        throw Failure(json["message"] as String);
      }

      final user = User.fromJson(json);

      return user;
    } on SocketException catch (_) {
      throw Failure("No internet connection");
    } on HttpException {
      throw Failure("Service not currently available");
    } on TimeoutException catch (_) {
      throw Failure("Poor internet connection");
    } on Failure catch (err) {
      throw Failure(err.message);
    } catch (err) {
      throw Failure("Something went wrong. Try again");
    }
  }
}
