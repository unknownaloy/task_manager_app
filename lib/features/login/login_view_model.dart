import 'package:flutter/material.dart';
import 'package:task_manager_app/core/data/models/user/user.dart';
import 'package:task_manager_app/core/data/unions/request_state.dart';
import 'package:task_manager_app/core/utils/failure.dart';
import 'package:task_manager_app/features/login/data/login_dto.dart';
import 'package:task_manager_app/features/login/repository/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required LoginRepository loginRepository,
  }) : _loginRepository = loginRepository;

  final LoginRepository _loginRepository;

  User? _user;

  RequestState _loginState = const RequestState.idle();
  RequestState get loginState => _loginState;

  Future<void> handleLogin({
    required String username,
    required String password,
  }) async {
    _loginState = const RequestState.loading();
    notifyListeners();

    try {
      final params = LoginDto(
        username: username,
        password: password,
      );
      _user = await _loginRepository.login(params);

      _loginState = const RequestState.success();
    } on Failure catch (err) {
      _loginState = RequestState.error(message: err.message);
    } finally {
      notifyListeners();
    }
  }
}
