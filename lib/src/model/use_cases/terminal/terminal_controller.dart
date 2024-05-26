import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/repositories/ssh/ssh_client.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
import 'package:xterm/xterm.dart';

import '../../../utils/extension.dart';
import '../../entities/ssh/host.dart';
import 'virtual_keyboard_controller.dart';

part 'terminal_controller.g.dart';

@riverpod
class CurrentHost extends _$CurrentHost {
  @override
  Future<Host> build() async {
    final sshHosts = ref.watch(sSHHostListProvider);
    return sshHosts.when(
      data: (loadedSshHosts) => loadedSshHosts.first,
      loading: () => throw Exception('Loading'),
      error: (error, _) => throw Exception('Error: $error'),
    );
  }

  Future<void> newHost(Host host) async {
    state = AsyncData(host);
  }
}

@riverpod
class TerminalController extends _$TerminalController {
  @override
  Future<Terminal> build(Host host) async {
    final repository = ref.watch(sshClientRepositoryProvider(host));
    await repository.connect();
    final virtualKeyboard = ref.watch(virtualKeyboardControllerProvider);
    final terminal =
        Terminal(onOutput: _inputHandler, inputHandler: virtualKeyboard);
    repository.stdout?.listen(terminal.write);
    repository.stderr?.listen(terminal.write);
    return terminal;
  }

  void _inputHandler(String? message) {
    if (message == null) {
      return;
    }
    debugPrint(message);
    ref.watch(sshClientRepositoryProvider(host)).stdin(message);
  }

  Future<String> run(String command) async {
    return state.when(
      data: (terminal) async {
        final repository = ref.watch(sshClientRepositoryProvider(host));
        if (!repository.connected) {
          throw Exception('Not connected');
        }
        // if command doesn't end with newline, add it
        repository.stdin(command.shouldEndWith('\n'));
        return '';
      },
      loading: () => throw Exception('Loading'),
      error: (error, _) => throw Exception('Error: $error'),
    );
  }
}
