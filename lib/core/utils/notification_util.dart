import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:task_manager_app/core/data/enums/notification_type.dart';

class NotificationUtil {
  factory NotificationUtil() => _instance;

  NotificationUtil._();

  static final NotificationUtil _instance = NotificationUtil._();

  void showNotification(
    String message, [
    NotificationType type = NotificationType.success,
  ]) {
    showSimpleNotification(
      Text(message),
      background: type.color,
    );
  }
}
