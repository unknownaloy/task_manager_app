import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager_app/core/data/data_source/local/task_database.dart';
import 'package:task_manager_app/core/data/data_source/local/user_data_source.dart';
import 'package:task_manager_app/core/data/models/user/user.dart';
import 'package:task_manager_app/core/data/unions/request_state.dart';
import 'package:task_manager_app/features/login/authentication_view_model.dart';
import 'package:task_manager_app/features/login/data/login_dto.dart';
import 'package:task_manager_app/features/login/repository/login_repository.dart';

import 'authentication_view_model_test.mocks.dart';

@GenerateMocks([LoginRepository, UserDataSource, TaskDatabase])
void main() {
  late AuthenticationViewModel sut;
  late MockLoginRepository mockLoginRepository;
  late MockUserDataSource mockUserDataSource;
  late MockTaskDatabase mockTaskDatabase;

  setUp(() {
    mockLoginRepository = MockLoginRepository();
    mockUserDataSource = MockUserDataSource();
    mockTaskDatabase = MockTaskDatabase();

    sut = AuthenticationViewModel(
      loginRepository: mockLoginRepository,
      userDataSource: mockUserDataSource,
      taskDatabase: mockTaskDatabase,
    );
  });

  final user = User(
    id: 1,
    username: "username",
    email: "email",
    firstName: "firstName",
    lastName: "lastName",
    gender: "gender",
    image: "image",
    token: "token",
  );

  const loginParams = LoginDto(
    username: "username",
    password: "password",
  );

  void initialAuthenticationViewModel() {
    when(mockLoginRepository.login(loginParams)).thenAnswer(
      (_) async => user,
    );
  }

  test("Test that initial values are correct", () {
    expect(
      sut.loginState,
      const RequestState.idle(),
    );
    expect(sut.user, null);
  });

  test("getCurrentUser uses the mockUserDataSource", () async {
    initialAuthenticationViewModel();

    await sut.getCurrentUser();
    verify(mockUserDataSource.getUser()).called(1);
  });

  test("""
    indicates loading of data, 
    set user to the one gotten from the service,
    indicates that the data is not being loaded anymore""", () async {
    initialAuthenticationViewModel();
    final future = sut.handleLogin(loginParams);
    expect(sut.loginState, const RequestState.loading());
    await future;

    expect(sut.loginState, const RequestState.success());
    expect(sut.user, user);
  });

  test("indicate that user is null after logging out", () async {
    await sut.handleSignOut();
    verify(mockTaskDatabase.clearDatabase()).called(1);

    expect(sut.user, null);
  });
}
