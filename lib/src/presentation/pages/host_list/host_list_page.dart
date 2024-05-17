import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/host_list/add_host_page.dart';

import '../../components/bottom_navigation_bar.dart';

class HostListPage extends ConsumerWidget {
  const HostListPage({super.key});

  static const String pageName = 'HostsListPage';
  static const String pagePath = '/hosts_list';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hosts = ref.watch(sSHHostListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hosts List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              GoRouter.of(context).push(AddHostPage.pagePath);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.read(sSHHostListProvider.notifier).deleteAll();
            },
          ),
        ],
      ),
      bottomNavigationBar: const MyBottomNavigationBar(),
      body: hosts.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stackTrace) => Text('Error: $error'),
        data: (loadedHosts) {
          if (loadedHosts.isEmpty) {
            return const Text('No hosts');
          }
          return ListView.builder(
            itemCount: loadedHosts.length,
            itemBuilder: (context, index) {
              final host = loadedHosts[index];
              return ListTile(
                title: Text(host.name),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
