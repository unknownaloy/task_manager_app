import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/features/login/login_view_model.dart';
import 'package:task_manager_app/features/task/presentation/task_view_model.dart';

class TaskUi extends StatefulWidget {
  const TaskUi({super.key});

  @override
  State<TaskUi> createState() => _TaskUiState();
}

class _TaskUiState extends State<TaskUi> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    context.read<TaskViewModel>().fetchTasks(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<LoginViewModel>().user!;
    return Consumer<TaskViewModel>(
      builder: (_, model, __) {
        return model.requestState.maybeWhen(
          orElse: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (message) => Scaffold(
            body: Center(
              child: Text(message),
            ),
          ),
          success: () => Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Hey ${user.firstName} ${user.lastName} 👋🏼",
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Add Task',
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
