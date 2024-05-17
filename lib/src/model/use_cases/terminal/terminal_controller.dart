import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/repositories/ssh/ssh_client.dart';
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
  Future<bool> build(Host host) async {
    final repository = ref.watch(sshClientRepositoryProvider(host));
    await repository.connect();
    return repository.connected;
  }

  Future<String> run(String command) async {
    return state.when(
      data: (state) async {
        if (!state) {
          throw Exception('Not connected');
        }
        final repository = ref.watch(sshClientRepositoryProvider(host));
        // repository.stdin(command);
        final result = await repository.run(command);
        ref.read(runResultsProvider(host).notifier).add(result);
        return '';
      },
      loading: () => throw Exception('Loading'),
      error: (error, _) => throw Exception('Error: $error'),
    );
  }
}
