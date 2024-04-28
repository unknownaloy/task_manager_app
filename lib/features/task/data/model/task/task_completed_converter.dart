import 'package:json_annotation/json_annotation.dart';

class TaskCompletedConverter implements JsonConverter<bool, dynamic> {
  const TaskCompletedConverter();

  @override
  bool fromJson(dynamic json) {
    // Check if the input is a bool or an int
    if (json is bool) {
      return json; // Return as is if it's already a bool
    } else if (json is int) {
      // Return true if int value is 1, false otherwise
      return json == 1;
    }
    // Throw an error if the input is neither a bool nor an int
    throw FormatException('Invalid value for completed: $json');
  }

  @override
  dynamic toJson(bool object) {
    // Convert the bool to an integer: 1 for true, 0 for false
    return object ? 1 : 0;
  }
}
