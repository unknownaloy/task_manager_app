import 'dart:async';

import 'package:flutter/material.dart';
import 'package:task_manager_app/core/data/data_source/local/task_database.dart';
import 'package:task_manager_app/core/data/enums/notification_type.dart';
import 'package:task_manager_app/core/data/unions/request_state.dart';
import 'package:task_manager_app/core/utils/failure.dart';
import 'package:task_manager_app/core/utils/notification_util.dart';
import 'package:task_manager_app/features/task/data/dto/add_task.dto.dart';
import 'package:task_manager_app/features/task/data/dto/task_dto.dart';
import 'package:task_manager_app/features/task/data/dto/update_task_dto.dart';
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
  TaskDto get taskDto => _taskDto;


  RequestState _requestState = const RequestState.idle();
  RequestState get requestState => _requestState;

  RequestState _addRequestState = const RequestState.idle();
  RequestState get addRequestState => _addRequestState;

  Future<void> fetchInitialTasks(TaskDto params) async {
    _requestState = const RequestState.loading();

    try {
      _taskDto = _taskDto.copyWith(skip: 0);
      _tasks = await _taskRepository.getUserTasks(params);

      _requestState = const RequestState.success();

      if (_tasks.isNotEmpty) {
        await _taskDatabase.cacheTasks(tasks);
      }

      _taskDto = _taskDto.copyWith(skip: _taskDto.skip + 10);
    } on Failure catch (err) {
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
      _requestState = RequestState.error(message: err.message);
    } finally {
      notifyListeners();
    }
  }

    Future<void> fetchMoreTasks(TaskDto params) async {
    try {
      if (_hasReachedMax || _isFetchingMoreData) return;

      _isFetchingMoreData = true;
      notifyListeners();

      final newTasks = await _taskRepository.getUserTasks(params);

      _taskDto = _taskDto.copyWith(skip: _taskDto.skip + 10);

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

      if (_tasks.isNotEmpty) {
        // unawaited(
          await _taskDatabase.cacheTasks(_tasks);
        // );
      }
    } on Failure catch (err) {
      _taskDto = _taskDto.copyWith(skip: _taskDto.skip - 10);
      NotificationUtil().showNotification(
        err.message,
        NotificationType.error,
      );
    }
  }

  Future<void> addNewTask(AddTaskDto params) async {
    _addRequestState = const RequestState.loading();

    notifyListeners();

    try {
      final task = await _taskRepository.addTask(params);

      final updatedTasks = [task, ..._tasks];

      _tasks = updatedTasks;

      _addRequestState = const RequestState.success();

      unawaited(
        _taskDatabase.cacheTasks(updatedTasks),
      );
    } on Failure catch (err) {
      _addRequestState = RequestState.error(message: err.message);
      NotificationUtil().showNotification(
        err.message,
        NotificationType.error,
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> editTask(Task taskToUpdate) async {
    final cachedTasks = [..._tasks];
    try {
      final completed = !taskToUpdate.completed;

      final updatedTask = taskToUpdate.copyWith(completed: completed);

      _tasks[_tasks.indexWhere((element) => element.id == taskToUpdate.id)] =
          updatedTask;

      notifyListeners();

      final params = UpdateTaskDto(completed: completed);
      await _taskRepository.updateTask(params);

      unawaited(
        _taskDatabase.updateTask(updatedTask),
      );
    } on Failure catch (err) {
      // Reverse optimistic update
      _tasks = cachedTasks;
      unawaited(
        _taskDatabase.updateTask(taskToUpdate),
      );
      NotificationUtil().showNotification(
        err.message,
        NotificationType.error,
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteTaskHandler(Task taskToDelete) async {
    final cachedTasks = [..._tasks];
    try {
      _tasks.remove(taskToDelete);
      notifyListeners();

      await _taskRepository.deleteTask();

      NotificationUtil().showNotification(
        "Success",
      );

      unawaited(
        _taskDatabase.deleteTask(taskToDelete),
      );
    } on Failure catch (err) {
      // Reverse optimistic update
      _tasks = cachedTasks;
      unawaited(
        _taskDatabase.cacheTasks(_tasks),
      );
      NotificationUtil().showNotification(
        err.message,
        NotificationType.error,
      );
    } finally {
      notifyListeners();
    }
  }
}
