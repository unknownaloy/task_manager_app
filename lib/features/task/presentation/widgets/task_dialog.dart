import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/core/data/unions/request_state.dart';
import 'package:task_manager_app/features/login/login_view_model.dart';
import 'package:task_manager_app/features/task/data/dto/add_task.dto.dart';
import 'package:task_manager_app/features/task/presentation/task_view_model.dart';

class TaskDialog extends StatefulWidget {
  const TaskDialog({
    super.key,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _taskController;

  @override
  void initState() {
    super.initState();

    _taskController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _taskController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TaskViewModel>();
    final user = context.read<LoginViewModel>().user!;

    if (model.addRequestState == const RequestState.success()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }
    
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Task",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            AbsorbPointer(
              absorbing: false,
              child: TextFormField(
                controller: _taskController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Task",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Task is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final params = AddTaskDto(
                    todo: _taskController.text.trim(),
                    userId: user.id,
                  );

                  model.addNewTask(params);
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
              child: model.addRequestState == const RequestState.loading()
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  : const Text(
                      "Add Task",
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
    );
  }
}
