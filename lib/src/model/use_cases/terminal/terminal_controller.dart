import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/repositories/ssh/ssh_client.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
import 'package:xterm/xterm.dart';

import '../../../utils/extension.dart';
import '../../entities/ssh/host.dart';
import '../../entities/terminal/run_result.dart';

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
class RunResults extends _$RunResults {
  @override
  List<RunResult> build(Host host) {
    final repository = ref.watch(sshClientRepositoryProvider(host));
    repository.stdout.listen(add);
    repository.stderr.listen(add);
    return [];
  }

  void add(String result) {
    final withoutEscape =
        result.replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '');
    state = [...state, RunResult(name: withoutEscape)];
  }
}

@riverpod
class TerminalController extends _$TerminalController {
  @override
  Future<Terminal> build(Host host) async {
    final repository = ref.watch(sshClientRepositoryProvider(host));
    await repository.connect();
    final terminal = Terminal(onOutput: _inputHandler);
    repository.stdout.listen(terminal.write);
    repository.stderr.listen(terminal.write);
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
