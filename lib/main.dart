import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/core/data/data_source/local/task_database.dart';
import 'package:task_manager_app/core/data/data_source/local/user_data_source.dart';
import 'package:task_manager_app/features/login/login_screen.dart';
import 'package:task_manager_app/features/login/login_view_model.dart';
import 'package:task_manager_app/features/login/repository/login_repository.dart';
import 'package:task_manager_app/features/task/presentation/task_screen.dart';
import 'package:task_manager_app/features/task/presentation/task_view_model.dart';
import 'package:task_manager_app/features/task/repository/task_repository.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            loginRepository: LoginRepository(),
            userDataSource: UserDataSource(),
          )..getCurrentUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskViewModel(
            taskRepository: TaskRepository(),
            taskDatabase: TaskDatabase(),
          ),
        ),
      ],
      child: OverlaySupport.global(
        child: MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.robotoTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: Consumer<LoginViewModel>(
            builder: (_, model, __) {
              if (model.user != null) {
                return const TaskScreen();
              }

              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
