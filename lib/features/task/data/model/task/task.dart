import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  factory Task({
    required int id,
    required String todo,
    required bool completed,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  @JsonKey(includeFromJson: false)
   static Task fromSqfliteDatabase(Map<String, dynamic> map) {
    return Task(
      id: map["id"] as int,
      todo: map["todo"] as String,
      completed: map["completed"] == 1,
    );
  }
}

// Define an extension outside of the Task class
extension TaskDatabaseExtensions on Task {

  Map<String, dynamic> toJsonSqfliteDatabase() {
    return {
      "id": id,
      "todo": todo,
      "completed": completed ? 1 : 0,
    };
  }
}
