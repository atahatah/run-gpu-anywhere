import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/virtual_keyboard_controller.dart';

class VirtualKeyboardView extends ConsumerWidget {
  const VirtualKeyboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboard = ref.watch(virtualKeyboardControllerProvider);
    return AnimatedBuilder(
      animation: keyboard,
      builder: (context, child) => ToggleButtons(
        isSelected: [
          keyboard.ctrl,
          keyboard.shift,
          keyboard.alt,
        ],
        onPressed: (index) => keyboard.update(
          ctrl: index == 0 ? !keyboard.ctrl : keyboard.ctrl,
          shift: index == 1 ? !keyboard.shift : keyboard.shift,
          alt: index == 2 ? !keyboard.alt : keyboard.alt,
        ),
        children: const [
          Text('ctrl'),
          Text('shift'),
          Text('alt'),
        ],
      ),
    );
  }
}
