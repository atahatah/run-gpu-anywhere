import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/terminal_controller.dart';

class TerminalPage extends ConsumerWidget {
  const TerminalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sshHosts = ref.watch(sSHHostListProvider);
    final currentHost = ref.watch(currentHostProvider);
    return switch (sshHosts) {
      AsyncError(:final error) => Text('Error: $error'),
      AsyncData(value: final loadedSshHosts) => switch (currentHost) {
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
                switch (ref.watch(runResultsProvider(loadedCurrentHost))) {
                  AsyncError(:final error) => Text('Error: $error'),
                  AsyncData(value: final results) => Column(
                      children: [
                        for (final result in results) Text(result.name),
                        Row(
                          children: [
                            Text('Command: '),
                            Text('_________'),
                            // add button
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Run'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  _ => const CircularProgressIndicator(),
                },
              ],
            ),
          _ => const CircularProgressIndicator(),
        },
      _ => const CircularProgressIndicator(),
    };
  }
}
