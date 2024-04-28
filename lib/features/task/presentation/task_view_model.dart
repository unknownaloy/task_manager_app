import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_manager_app/core/data/data_source/local/task_database.dart';
import 'package:task_manager_app/core/data/enums/notification_type.dart';
import 'package:task_manager_app/core/data/unions/request_state.dart';
import 'package:task_manager_app/core/utils/failure.dart';
import 'package:task_manager_app/core/utils/notification_util.dart';
import 'package:task_manager_app/features/task/data/dto/task_dto.dart';
import 'package:task_manager_app/features/task/data/model/task/task.dart';
import 'package:task_manager_app/features/task/repository/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel({
    required TaskRepository taskRepository,
    required TaskDatabase taskDatabase,
  })  : _taskRepository = taskRepository,
        _taskDatabase = taskDatabase;

  final TaskRepository _taskRepository;
  final TaskDatabase _taskDatabase;


  var _tasks = <Task>[];
  List<Task> get tasks => [..._tasks];

  bool _hasReachedMax = false;
  bool _isFetchingMoreData = false;
  bool get isFetchingMoreData => _isFetchingMoreData;

  var _taskDto = const TaskDto(skip: 0);

  RequestState _requestState = const RequestState.idle();
  RequestState get requestState => _requestState;

  Future<void> fetchInitialTasks() async {
    _requestState = const RequestState.loading();

    try {
      _taskDto = _taskDto.copyWith(skip: 0);
      _tasks = await _taskRepository.getUserTasks(_taskDto);

      _requestState = const RequestState.success();

      if (_tasks.isNotEmpty) {
        await _taskDatabase.cacheTasks(tasks);
      }
    } on Failure catch (err) {
      // Handle error
      _requestState = RequestState.error(message: err.message);
    } finally {
      notifyListeners();
    }
  }


  Future<void> loadFromCache() async {
    _requestState = const RequestState.loading();

    try {
      _tasks = await _taskDatabase.getAllTasks();

      _requestState = const RequestState.success();

    } on Failure catch (err) {
      // Handle error
      _requestState = RequestState.error(message: err.message);
    } finally {
      notifyListeners();
    }
  }



  Future<void> fetchMoreTasks() async {
    try {
      if (_hasReachedMax || _isFetchingMoreData) return;

      _isFetchingMoreData = true;
      notifyListeners();

      _taskDto = _taskDto.copyWith(skip: _taskDto.skip + 10);

      final newTasks = await _taskRepository.getUserTasks(_taskDto);

      if (newTasks.length < _taskDto.limit || newTasks.isEmpty) {
        _hasReachedMax = true;
        _isFetchingMoreData = false;
        notifyListeners();

        // No more tasks to fetch
        return;
      }

      final updatedTasks = [..._tasks, ...newTasks];

      _tasks = updatedTasks;
      _isFetchingMoreData = false;
      notifyListeners();
    } on Failure catch (err) {
      _taskDto = _taskDto.copyWith(skip: _taskDto.skip - 10);
      NotificationUtil.showNotification(
        err.message,
        NotificationType.error,
      );
    }
  }


}
