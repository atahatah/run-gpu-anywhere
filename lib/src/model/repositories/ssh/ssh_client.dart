import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../entities/ssh/host.dart';

part 'ssh_client.g.dart';

@riverpod
class SSHClientWrapper extends _$SSHClientWrapper {
  late SSHSession shell;
  @override
  Future<SSHClient> build(Host host) async {
    // connect to the host and open a shell
    debugPrint('loading ssh client...');
    final socket = await SSHSocket.connect(host.ip, host.port);
    debugPrint('connected to host');
    debugPrint('authenticating...');
    final client = SSHClient(
      socket,
      username: host.userName,
      onPasswordRequest: () => host.password,
    );
    debugPrint('authenticated');
    debugPrint('opening shell...');
    shell = await client.shell();
    debugPrint('shell opened');

    ref.onDispose(() async {
      debugPrint('closing shell...');
      await shell.done;
      debugPrint('shell closed');
      debugPrint('closing client...');
      client.close();
      debugPrint('client closed');
    });

    debugPrint('success loading ssh client');
    return client;
  }

  Future<String> run(String command) async {
    // wait for the client to be loaded
    return await state.when(
      data: (client) async {
        final result = await client.run(command);
        return utf8.decode(result);
      },
      loading: () => 'loading',
      error: (error, _) => 'error',
    );
  }
}
