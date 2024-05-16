import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
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
  Future<List<RunResult>> build(Host host) async {
    debugPrint('loading run results...');
    await Future<void>.delayed(const Duration(seconds: 1));
    return [RunResult(name: 'result1'), RunResult(name: 'result2')];
  }

  Future<void> fetch() async {
    state = const AsyncLoading();
    final results = await build(host);
    state = AsyncData(results);
  }
}

@riverpod
class TerminalController extends _$TerminalController {
  @override
  Future<Host> build(Host host) async {
    debugPrint('connecting to host...');
    await Future<void>.delayed(const Duration(seconds: 1));
    return host;
  }

  Future<void> run(String command) async {
    debugPrint('running command...');
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
