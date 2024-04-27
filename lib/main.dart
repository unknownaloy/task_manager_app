import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/core/data/data_source/local/user_data_source.dart';
import 'package:task_manager_app/features/login/login_screen.dart';
import 'package:task_manager_app/features/login/login_view_model.dart';
import 'package:task_manager_app/features/login/repository/login_repository.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LoginViewModel(
        loginRepository: LoginRepository(),
        userDataSource: UserDataSource(),
      )..getCurrentUser(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (_, model, __) => OverlaySupport.global(
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
            home: model.user != null
                ? Container(
                    color: Colors.green,
                  )
                : const LoginScreen(),
          ),
        ),
    );
  }
}
