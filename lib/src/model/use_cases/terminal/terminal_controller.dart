import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';
import '../../entities/ssh/host.dart';

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

  void newHost(Host host) {
    state = AsyncData(host);
  }
}
