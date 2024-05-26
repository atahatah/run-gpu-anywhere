import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/terminal_controller.dart';
import 'package:run_gpu_anywhere/src/presentation/components/bottom_navigation_bar.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/terminal/input_suggester.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/terminal/virtual_keyboard.dart';
import 'package:xterm/xterm.dart';

import '../../../model/entities/ssh/host.dart';

class TerminalPage extends HookConsumerWidget {
  const TerminalPage({super.key});

  static const pageName = 'TerminalPage';
  static const pagePath = '/terminal';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sshHosts = ref.watch(sSHHostListProvider);
    final currentHost = ref.watch(currentHostProvider);
    final manually = useState<bool>(false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
      ),
      bottomNavigationBar: const MyBottomNavigationBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                        SelectHost(
                          currentHost: loadedCurrentHost,
                          sshHosts: loadedSshHosts,
                        ),
                        Switch(
                          value: manually.value,
                          onChanged: (value) {
                            manually.value = value;
                          },
                        ),
                        TerminalComponent(
                          host: loadedCurrentHost,
                          manually: manually.value,
                        ),
                      ],
                    ),
                  _ => const CircularProgressIndicator(),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SelectHost extends ConsumerWidget {
  const SelectHost({
    super.key,
    required this.currentHost,
    required this.sshHosts,
  });

  final Host currentHost;
  final List<Host> sshHosts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton(
      value: currentHost,
      items: [
        for (final sshHost in sshHosts)
          DropdownMenuItem(
            value: sshHost,
            child: Text(sshHost.name),
          ),
      ],
      onChanged: (selectedHost) {
        if (selectedHost == null) {
          return;
        }
        ref.read(currentHostProvider.notifier).newHost(selectedHost);
      },
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
              height: 300,
              child: TerminalView(
                terminal,
                deleteDetection: true,
                readOnly: !manually,
              ),
            ),
            if (manually) const VirtualKeyboardView(),
            if (!manually) const InputSuggester(),
          ],
        ),
      _ => const CircularProgressIndicator(),
    };
  }
}
