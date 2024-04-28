import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/core/data/enums/notification_type.dart';
import 'package:task_manager_app/core/utils/notification_util.dart';
import 'package:task_manager_app/features/task/data/dto/task_dto.dart';
import 'package:task_manager_app/features/task/presentation/task_view_model.dart';
import 'package:task_manager_app/features/task/presentation/widgets/task_app_bar.dart';
import 'package:task_manager_app/features/task/presentation/widgets/task_card.dart';
import 'package:task_manager_app/features/task/presentation/widgets/task_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final ScrollController _scrollController;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isAtBottom = false;
  bool _isLoadingMoreData = false;

  bool _hasInternetConnection = true;
  bool _isLoadedFromCache = false;

  void _scrollListenerHandler() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = MediaQuery.of(context).size.height * 0.20;

    if (maxScroll - currentScroll <= delta) {
      if (_hasInternetConnection) {
        final params = context.read<TaskViewModel>().taskDto;
        context.read<TaskViewModel>().fetchMoreTasks(params);
      }
    }

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() => _isAtBottom = true);
    } else {
      setState(() => _isAtBottom = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final taskViewModel = context.read<TaskViewModel>();
      final hasConnection = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);

      setState(() => _hasInternetConnection = hasConnection);

      if (hasConnection) {
        if (_isLoadedFromCache) {
          NotificationUtil().showNotification(
            "Tasks updated",
          );
        }
        if (_isLoadedFromCache || taskViewModel.tasks.isEmpty) {
          const params = TaskDto(skip: 0);
          taskViewModel.fetchInitialTasks(params);
        }
      } else {
        if (taskViewModel.tasks.isEmpty) {
          taskViewModel.loadFromCache();

          NotificationUtil().showNotification(
            "Loaded from cache",
            NotificationType.caution,
          );
          setState(() {
            _isLoadedFromCache = true;
          });
        } else {
          NotificationUtil().showNotification(
            "Internet connection lost",
            NotificationType.caution,
          );
        }
      }
    });

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListenerHandler);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            appBar: const TaskAppBar(),
            body: RefreshIndicator(
              onRefresh: () {
                const params = TaskDto(skip: 0);
                return model.fetchInitialTasks(params);
              },
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Text(message),
                    ),
                  ),
                ],
              ),
            ),
          ),
          success: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (model.isFetchingMoreData) {
                setState(() => _isLoadingMoreData = true);
              } else {
                setState(() => _isLoadingMoreData = false);
              }
            });

            return Scaffold(
              appBar: const TaskAppBar(),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () {
                      const params = TaskDto(skip: 0);
                      return model.fetchInitialTasks(params);
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TaskCard(
                                      task: task,
                                      onEdit: () => model.editTask(task),
                                      onDelete: () =>
                                          model.deleteTaskHandler(task),
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
                        SliverToBoxAdapter(
                          child: _isAtBottom && _isLoadingMoreData
                              ? Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 4,
                                    ),
                                    width: 18,
                                    height: 18,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Dialog(
                      child: TaskDialog(),
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
