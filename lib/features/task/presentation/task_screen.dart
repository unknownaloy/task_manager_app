import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/features/login/login_view_model.dart';
import 'package:task_manager_app/features/task/presentation/task_view_model.dart';
import 'package:task_manager_app/features/task/presentation/widgets/task_card.dart';
import 'package:task_manager_app/features/task/presentation/widgets/task_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
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
          success: () {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text(
                  "Hey ${user.firstName} ${user.lastName} 👋🏼",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                actions: [
                  CircleAvatar(
                    radius: 23,
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(23),
                      ),
                      child: Image.network(user.image),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: Text(
                          "Tasks",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (model.tasks.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: Icon(
                              Icons.folder_delete_rounded,
                              size: 128,
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              final task = model.tasks[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TaskCard(
                                    task: task,
                                    onEdit: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: TaskDialog(
                                            title: "Edit Task",
                                            task: task,
                                          ),
                                        ),
                                      );
                                    },
                                    onDelete: () {},
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              );
                            },
                            childCount: model.tasks.length,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => const Dialog(
                      child: TaskDialog(
                        title: "Add Task",
                      ),
                    ),
                  );
                },
                tooltip: 'Add Task',
                child: const Icon(Icons.add),
              ),
            );
          },
        );
      },
    );
  }
}
