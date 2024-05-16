import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../entities/ssh/host.dart';

part 'ssh_host_controller.g.dart';

/// SSHの接続先ホストを管理する
@riverpod
class SSHHostList extends _$SSHHostList {
  List<Host>? sshHostList = [Host(name: 'host1'), Host(name: 'host2')];

  /// SSHの接続先ホストのリストを取得する
  Future<List<Host>> build() async => sshHostList!;
}
