import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/features/login/authentication_view_model.dart';

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TaskAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthenticationViewModel>();
    final user = authViewModel.user!;
    return AppBar(
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
            child: CachedNetworkImage(
              imageUrl: user.image,
              placeholder: (context, url) => Container(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        IconButton(
          onPressed: authViewModel.handleSignOut,
          icon: const Icon(
            Icons.logout,
            size: 40,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
