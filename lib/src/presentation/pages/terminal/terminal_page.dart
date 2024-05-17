import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/terminal_controller.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/host_list/host_list_page.dart';

import '../../../model/entities/ssh/host.dart';

class TerminalPage extends ConsumerWidget {
  const TerminalPage({super.key});

  static String get pageName => 'TerminalPage';
  static String get pagePath => '/terminal';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sshHosts = ref.watch(sSHHostListProvider);
    final currentHost = ref.watch(currentHostProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).push(HostListPage.pagePath);
            },
            child: const Text('Add Host'),
          ),
          sshHosts.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => Text('Error: $error'),
            data: (loadedSshHosts) {
              if (loadedSshHosts.isEmpty) {
                return const Text('No hosts');
              }
              return switch (currentHost) {
                AsyncError(:final error) => Text('Error: $error'),
                AsyncData(value: final loadedCurrentHost) => Column(
                    children: [
                      DropdownButton(
                        value: loadedCurrentHost,
                        items: [
                          for (final sshHost in loadedSshHosts)
                            DropdownMenuItem(
                              value: sshHost,
                              child: Text(sshHost.name),
                            ),
                        ],
                        onChanged: (selectedHost) {
                          if (selectedHost == null) {
                            return;
                          }
                          ref
                              .read(currentHostProvider.notifier)
                              .newHost(selectedHost);
                        },
                      ),
                      SizedBox(
                        height: 400,
                        child: RunResultComponent(
                          loadedCurrentHost: loadedCurrentHost,
                        ),
                      ),
                    ],
                  ),
                _ => const CircularProgressIndicator(),
              };
            },
          ),
        ],
      ),
    );
  }
}

class RunResultComponent extends ConsumerWidget {
  const RunResultComponent({
    super.key,
    required this.loadedCurrentHost,
  });

  final Host loadedCurrentHost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runResults = ref.watch(runResultsProvider(loadedCurrentHost));
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final result in runResults) Text(result.name),
          Row(
            children: [
              const Text('Command: '),
              const Text('_________'),
              // add button
              ElevatedButton(
                onPressed: () {},
                child: const Text('Run'),
              ),
            ],
          ),
          DebugComponent(host: loadedCurrentHost),
        ],
      ),
    );
  }
}

class DebugComponent extends ConsumerWidget {
  const DebugComponent({super.key, required this.host});
  final Host host;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runnerState = ref.watch(terminalControllerProvider(host));
    final runner = ref.read(terminalControllerProvider(host).notifier);
    return switch (runnerState) {
      AsyncError(:final error) => Text('Error: $error'),
      AsyncData(value: final _) => ElevatedButton(
          onPressed: () async {
            final result = await runner.run('pwd');
            debugPrint(result);
          },
          child: const Text('Debug'),
        ),
      _ => const CircularProgressIndicator(),
    };
  }
}
