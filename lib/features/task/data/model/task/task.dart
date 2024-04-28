import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_manager_app/features/task/data/model/task/task_completed_converter.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  factory Task({
    required int id,
    required String todo,

    @TaskCompletedConverter()
    required bool completed,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}