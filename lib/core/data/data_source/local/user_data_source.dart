import 'dart:convert';

import 'package:flutter/material.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/core/data/models/user/user.dart';
import 'package:task_manager_app/core/utils/strings.dart';
import 'package:task_manager_app/core/utils/typedefs.dart';

class UserDataSource {
  factory UserDataSource() => _instance;

  UserDataSource._();

  static final UserDataSource _instance = UserDataSource._();

  Future<void> cacheUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await prefs.setString(
        userKey,
        json.encode(
          user.toJson(),
        ),
      );
    } catch (err) {
      debugPrint("UserDataSource - cacheUser -- err -> $err");
    }
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final userString = prefs.getString(userKey);
      if (userString != null) {
        final userJSON = json.decode(userString) as JSON;
        return User.fromJson(userJSON);
      }
    } catch (err) {
      debugPrint("UserDataSource - getUser -- err -> $err");
    }
    return null;
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await prefs.remove(userKey);
    } catch (err) {
      debugPrint("UserDataSource - deleteUser -- err -> $err");
    }
  }
}
