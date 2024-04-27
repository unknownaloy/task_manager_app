import 'package:flutter/material.dart';

enum NotificationType {
  success(Colors.green),
  caution(Colors.orange),
  error(Colors.red);

  const NotificationType(this.color);
  final Color color;
}
