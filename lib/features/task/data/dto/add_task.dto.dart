import 'dart:convert';

class AddTaskDto {
  const AddTaskDto({
    required this.todo,
    required this.userId,
  });

  final String todo;
  final int userId;

  String toJson() {
    final json = {
      "todo": todo,
      "userId": userId,
      "completed": false,
    };

    return jsonEncode(json);
  }
}
