import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/entities/terminal/virtual_keyboard_state.dart';
import 'package:xterm/xterm.dart';

part 'virtual_keyboard_controller.g.dart';

@Riverpod(keepAlive: true)
VirtualKeyboard virtualKeyboardController(
  VirtualKeyboardControllerRef ref,
) {
  return VirtualKeyboard(defaultInputHandler);
}

class VirtualKeyboard extends TerminalInputHandler with ChangeNotifier {
  VirtualKeyboard(this.inputHandler);
  VirtualKeyboardState state = const VirtualKeyboardState(
    ctrl: false,
    shift: false,
    alt: false,
  );
  final TerminalInputHandler inputHandler;

  bool get ctrl => state.ctrl;
  bool get shift => state.shift;
  bool get alt => state.alt;

  void update({
    bool? ctrl,
    bool? shift,
    bool? alt,
  }) {
    state = state.copyWith(
      ctrl: ctrl ?? state.ctrl,
      shift: shift ?? state.shift,
      alt: alt ?? state.alt,
    );
    notifyListeners();
  }

  @override
  String? call(TerminalKeyboardEvent event) {
    return inputHandler.call(
      event.copyWith(
        ctrl: event.ctrl || state.ctrl,
        shift: event.shift || state.shift,
        alt: event.alt || state.alt,
      ),
    );
  }
}
