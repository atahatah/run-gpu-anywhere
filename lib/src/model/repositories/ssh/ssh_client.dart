import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../entities/ssh/host.dart';

part 'ssh_client.g.dart';

@Riverpod(keepAlive: true)
SSHClientWrapper sshClientRepository(SshClientRepositoryRef ref, Host host) {
  return SSHClientWrapper(host);
}

class SSHClientWrapper {
  SSHClientWrapper(this.host);
  final Host host;
  SSHClient? _client;
  SSHSession? _shell;
  bool _loading = false;
  bool _connected = false;

  bool get loading => _loading;
  bool get connected => _connected;
  Stream<String>? get stdout {
    try {
      return _shell?.stdout
          .cast<List<int>>()
          .transform<String>(const Utf8Decoder(allowMalformed: true));
    } on FormatException catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Stream<String>? get stderr {
    try {
      return _shell?.stderr
          .cast<List<int>>()
          .transform<String>(const Utf8Decoder(allowMalformed: true));
    } on FormatException catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  void stdin(String value) {
    _shell!.stdin.add(utf8.encode(value));
  }

  Future<(SSHClient, SSHSession)> _connect() async {
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
    final shell = await client.shell(environment: {'LANG': host.lang});
    debugPrint('shell opened');

    debugPrint('success loading ssh client');
    return (client, shell);
  }

  Future<void> connect() async {
    _loading = true;
    try {
      final result = await _connect();
      _client = result.$1;
      _shell = result.$2;
      _connected = true;
    } finally {
      _loading = false;
    }
  }

  Future<void> disconnect() async {
    debugPrint('closing shell...');
    _client?.close();
    await _shell?.done;
    debugPrint('shell closed');
    debugPrint('closing client...');
    _client?.close();
    debugPrint('client closed');
    _connected = false;
  }

  Future<String> run(String command) async {
    if (!_connected) {
      throw Exception('Not connected');
    }
    final result = await _client?.run(command);
    return utf8.decode(result!);
  }
}
