import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:task_manager_app/core/data/data_source/local/task_database.dart';
import 'package:task_manager_app/core/network_manager/network_util.dart';
import 'package:task_manager_app/core/utils/failure.dart';
import 'package:task_manager_app/core/utils/typedefs.dart';
import 'package:task_manager_app/features/task/data/dto/task_dto.dart';
import 'package:task_manager_app/features/task/data/model/task/task.dart';

class TaskRepository {
  factory TaskRepository() => _instance;

  TaskRepository._internal(this._network);

  static final TaskRepository _instance =
      TaskRepository._internal(NetworkUtil());

  final NetworkUtil _network;

  Future<List<Task>> getUserTasks(TaskDto params) async {
    try {
      final url = Uri.parse("/todos");

      final response = await _network.client.get(
        url.replace(
          queryParameters: params.toJson(),
        ),
      );

      final json = jsonDecode(response.body) as JSON;

      if (response.statusCode == 400) {
        throw Failure(json["message"] as String? ?? "Something went wrong");
      }

      final listOfTask = json["todos"] as List<dynamic>;
      final tasks = <Task>[];

      for (final data in listOfTask) {
        final task = Task.fromJson(data as JSON);

        tasks.add(task);
      }

      return tasks;
    } on SocketException catch (_) {
      try {
        final tasks = await TaskDatabase().getAllTasks();

        return Future.value(tasks);
      } catch (_) {
        throw Failure("No internet connection");
      }
    } on HttpException {
      throw Failure("Service not currently available");
    } on TimeoutException catch (_) {
      throw Failure("Poor internet connection");
    } on Failure catch (err) {
      throw Failure(err.message);
    } catch (err) {
      throw Failure("Something went wrong. Try again");
    }
  }
}
