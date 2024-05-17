import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:xterm/xterm.dart';

import '../../../model/entities/ssh/host.dart';
import 'vertural_keyboard.dart';

class XTermSample extends StatefulWidget {
  XTermSample({super.key, required Host host})
      : host = host.ip,
        port = host.port,
        username = host.userName,
        password = host.password;
  final String host;
  final int port;
  final String username;
  final String password;

  @override
  // ignore: library_private_types_in_public_api
  _XTermSampleState createState() => _XTermSampleState();
}

class _XTermSampleState extends State<XTermSample> {
  late final terminal = Terminal(inputHandler: keyboard);

  final keyboard = MyVirtualKeyboard(defaultInputHandler);

  late String title = widget.host;

  @override
  void initState() {
    super.initState();
    initTerminal();
  }

  Future<void> initTerminal() async {
    terminal.write('Connecting...\r\n');

    final client = SSHClient(
      await SSHSocket.connect(widget.host, widget.port),
      username: widget.username,
      onPasswordRequest: () => widget.password,
    );

    terminal.write('Connected\r\n');

    final session = await client.shell(
      pty: SSHPtyConfig(
        width: terminal.viewWidth,
        height: terminal.viewHeight,
      ),
    );

    terminal.buffer.clear();
    terminal.buffer.setCursor(0, 0);

    terminal.onTitleChange = (title) {
      setState(() => this.title = title);
    };

    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      session.resizeTerminal(width, height, pixelWidth, pixelHeight);
    };

    terminal.onOutput = (data) {
      session.write(utf8.encode(data));
    };

    session.stdout
        .cast<List<int>>()
        .transform(Utf8Decoder())
        .listen(terminal.write);

    session.stderr
        .cast<List<int>>()
        .transform(Utf8Decoder())
        .listen(terminal.write);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: TerminalView(terminal),
        ),
        MyVirtualKeyboardView(keyboard),
      ],
    );
  }
}
