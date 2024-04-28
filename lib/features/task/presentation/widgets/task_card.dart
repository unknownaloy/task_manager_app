import 'package:flutter/material.dart';
import 'package:task_manager_app/features/task/data/model/task/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                task.todo,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
