import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/virtual_keyboard_controller.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/terminal_controller.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/host_list/host_list_page.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/terminal/vertural_keyboard.dart';
import 'package:xterm/xterm.dart';

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
                      TerminalComponent(
                        host: loadedCurrentHost,
                        manually: false,
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

class TerminalComponent extends ConsumerWidget {
  const TerminalComponent({
    super.key,
    required this.host,
    required this.manually,
  });

  final Host host;
  final bool manually;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terminal = ref.watch(terminalControllerProvider(host));
    return switch (terminal) {
      AsyncError(:final error) => Text('Error: $error'),
      AsyncData(value: final terminal) => Column(
          children: [
            SizedBox(
              height: 200,
              child: TerminalView(
                terminal,
                deleteDetection: true,
                readOnly: !manually,
              ),
            ),
            if (manually) const VirtualKeyboardView(),
            if (!manually) const SizedBox(height: 0),
          ],
        ),
      _ => const CircularProgressIndicator(),
    };
  }
}
