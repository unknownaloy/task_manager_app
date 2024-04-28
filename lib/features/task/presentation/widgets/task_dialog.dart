import 'package:flutter/material.dart';
import 'package:task_manager_app/features/task/data/model/task/task.dart';

class TaskDialog extends StatefulWidget {
  const TaskDialog({
    required this.title,
    this.task,
    super.key,
  });

  final String title;
  final Task? task;

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _taskController;

  @override
  void initState() {
    super.initState();

    _taskController = TextEditingController(text: widget.task?.todo ?? "");
  }

  @override
  void dispose() {
    super.dispose();

    _taskController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
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
                  // model.handleLogin(
                  //   username: _usernameTextController.text.trim(),
                  //   password: _passwordTextController.text.trim(),
                  // );
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
              child: 1 + 1 == 3
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  : Text(
                      widget.title,
                      style: const TextStyle(
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
