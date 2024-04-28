import 'dart:convert';

class UpdateTaskDto {
  const UpdateTaskDto({
    required this.completed,
    this.id = 150,
  });

  final int id;
  final bool completed;

  String toJson() {
    final json = {
      "completed": completed,
    };

    return jsonEncode(json);
  }
}
