import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../entities/ssh/host.dart';

part 'ssh_host_controller.g.dart';

/// SSHの接続先ホストを管理する
@riverpod
class SSHHostList extends _$SSHHostList {
  @override
  Future<List<Host>> build() async {
    return loadAllHosts();
  }

  /// SSHの接続先ホストのリストを取得する
  Future<List<Host>> loadAllHosts() async {
    debugPrint('loading ssh host list...');
    final prefs = await SharedPreferences.getInstance();
    final hostNames = prefs.getStringList('hostNames') ?? [];
    debugPrint('loaded ssh host list');
    debugPrint('loading each host info...');
    final hosts = <Host>[];
    const secureStorage = FlutterSecureStorage();
    for (final hostName in hostNames) {
      final ip = prefs.getString('$hostName.ip');
      final port = prefs.getInt('$hostName.port');
      final username = prefs.getString('$hostName.username');
      final password = await secureStorage.read(key: '$hostName.password');
      if (ip == null || port == null || username == null || password == null) {
        debugPrint('failed to load host info: $hostName');
        continue;
      }
      hosts.add(
        Host(
          name: hostName,
          ip: ip,
          port: port,
          userName: username,
          password: password,
        ),
      );
    }
    return hosts;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    final newHostsList = await loadAllHosts();
    state = AsyncData(newHostsList);
  }

  Future<void> addHost(Host host) async {
    await state.when(
      data: (hosts) async {
        final prefs = await SharedPreferences.getInstance();
        final hostNames = prefs.getStringList('hostNames') ?? [];
        if (hostNames.contains(host.name)) {
          throw Exception('Host already exists');
        }
        hostNames.add(host.name);
        await prefs.setStringList('hostNames', hostNames);
        await prefs.setString('${host.name}.ip', host.ip);
        await prefs.setInt('${host.name}.port', host.port);
        await prefs.setString('${host.name}.username', host.userName);
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: '${host.name}.password',
          value: host.password,
        );
        state = const AsyncLoading();
        final newHostsList = await loadAllHosts();
        state = AsyncData(newHostsList);
      },
      loading: () => throw Exception('Loading'),
      error: (error, _) => throw Exception('Error: $error'),
    );
  }

  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hostNames');
    final hostNames = prefs.getStringList('hostNames') ?? [];
    for (final hostName in hostNames) {
      await prefs.remove('$hostName.ip');
      await prefs.remove('$hostName.port');
      await prefs.remove('$hostName.username');
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: '$hostName.password');
    }
    state = const AsyncLoading();
    final newHostsList = await loadAllHosts();
    state = AsyncData(newHostsList);
  }
}
