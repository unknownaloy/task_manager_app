import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager_app/core/data/data_source/local/task_database.dart';
import 'package:task_manager_app/core/data/unions/request_state.dart';
import 'package:task_manager_app/features/task/data/dto/task_dto.dart';
import 'package:task_manager_app/features/task/data/model/task/task.dart';
import 'package:task_manager_app/features/task/presentation/task_view_model.dart';
import 'package:task_manager_app/features/task/repository/task_repository.dart';

import 'task_view_model_test.mocks.dart';

@GenerateMocks([TaskRepository, TaskDatabase])
void main() {
  late TaskViewModel sut;
  late MockTaskRepository mockTaskRepository;
  late MockTaskDatabase mockTaskDatabase;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockTaskDatabase = MockTaskDatabase();

    sut = TaskViewModel(
      taskRepository: mockTaskRepository,
      taskDatabase: mockTaskDatabase,
    );
  });

  final tasks = [
    Task(
      id: 1,
      todo: "The quick brown fox jumps over the lazy dog",
      completed: false,
    ),
  ];

  final taskParams = TaskDto(skip: 0);

  void initialTasks() {
    when(mockTaskRepository.getUserTasks(taskParams)).thenAnswer(
      (_) async => tasks,
    );
  }

  void getTasksFromCache() {
    when(mockTaskDatabase.getAllTasks()).thenAnswer(
      (_) async => tasks,
    );
  }

  test("Test that initial values are correct", () {
    expect(sut.requestState, const RequestState.idle());
    expect(sut.addRequestState, const RequestState.idle());
    expect(sut.tasks, <Task>[]);
    expect(sut.isFetchingMoreData, false);
  });

  test("getUserTask uses the mockTaskRepository", () async {
    initialTasks();

    await sut.fetchInitialTasks(taskParams);
    verify(mockTaskRepository.getUserTasks(taskParams)).called(1);
  });

  group("fetchInitialTasks", () {
    test("fetchInitialTasks uses the mockTaskRepository", () async {
      initialTasks();
      final future = sut.fetchInitialTasks(taskParams);
      expect(sut.requestState, const RequestState.loading());

      await future;
      verify(mockTaskDatabase.cacheTasks(tasks)).called(1);
      expect(sut.requestState, const RequestState.success());
      expect(sut.tasks, tasks);
    });
  });

  group("loadFromCache", () {
    test("loadFromCache uses the mockTaskDatabase and also updates the state",
        () async {
      getTasksFromCache();
      final future = sut.loadFromCache();
      expect(sut.requestState, const RequestState.loading());

      await future;
      verify(mockTaskDatabase.getAllTasks()).called(1);
      expect(sut.requestState, const RequestState.success());
      expect(sut.tasks, tasks);
    });
  });
  group("fetchMoreTasks", () {
    test(
        "fetchMoreTasks uses the mockTaskRepository, mockTaskDatabase and also updates the state tasks is less than 10 so break in code will be observed",
        () async {
      initialTasks();
      final future = sut.fetchMoreTasks(taskParams);
      expect(sut.isFetchingMoreData, true);

      await future;
      expect(sut.isFetchingMoreData, false);
    });
  });
}
