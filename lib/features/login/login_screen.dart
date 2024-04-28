import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/core/data/enums/notification_type.dart';
import 'package:task_manager_app/core/data/unions/request_state.dart';
import 'package:task_manager_app/core/utils/notification_util.dart';
import 'package:task_manager_app/features/login/authentication_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameTextController;
  late final TextEditingController _passwordTextController;

  @override
  void initState() {
    super.initState();

    _usernameTextController = TextEditingController();
    _passwordTextController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Task Manager',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Consumer<AuthenticationViewModel>(
          builder: (_, model, __) {
            final isLoading = model.loginState == const RequestState.loading();

            model.loginState.maybeWhen(
              success: () {
                // Navigate to dashboard
              },
              error: (message) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  NotificationUtil().showNotification(
                    message,
                    NotificationType.error,
                  );
                });
              },
              orElse: () {},
            );

            return Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AbsorbPointer(
                          absorbing: isLoading,
                          child: TextFormField(
                            controller: _usernameTextController,
                            decoration: InputDecoration(
                              hintText: "Username",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Username is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        AbsorbPointer(
                          absorbing: isLoading,
                          child: TextFormField(
                            controller: _passwordTextController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Password",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              model.handleLogin(
                                username: _usernameTextController.text.trim(),
                                password: _passwordTextController.text.trim(),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color(0xff2C64C6),
                            ),
                            minimumSize: MaterialStateProperty.all(
                              const Size.fromHeight(56),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Log In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
