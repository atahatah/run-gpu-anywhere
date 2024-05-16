import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/host_list/host_list_page.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/terminal/terminal_page.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  static String get pageName => 'MainPage';
  static String get pagePath => '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Run GPU Anywhere'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).push(TerminalPage.pagePath);
              },
              child: const Text('Terminal'),
            ),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).push(HostListPage.pagePath);
              },
              child: const Text('Host List'),
            )
          ],
        ));
  }
}
