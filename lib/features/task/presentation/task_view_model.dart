import 'package:flutter/cupertino.dart';
import 'package:task_manager_app/core/data/unions/request_state.dart';
import 'package:task_manager_app/core/utils/failure.dart';
import 'package:task_manager_app/features/task/data/dto/task_dto.dart';
import 'package:task_manager_app/features/task/data/model/task/task.dart';
import 'package:task_manager_app/features/task/repository/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel({
    required TaskRepository taskRepository,
  }) : _taskRepository = taskRepository;

  final TaskRepository _taskRepository;

  var _tasks = <Task>[];
  List<Task> get tasks => [..._tasks];

  RequestState _requestState = const RequestState.idle();
  RequestState get requestState => _requestState;

  Future<void> fetchTasks(int currentIndex) async {
    _requestState = const RequestState.loading();

    try {
      final params = TaskDto(skip: currentIndex);
      _tasks = await _taskRepository.getUserTasks(params);

      _requestState = const RequestState.success();
    } on Failure catch (err) {
      // Handle error
      _requestState = RequestState.error(message: err.message);
    } finally {
      notifyListeners();
    }
  }
}
