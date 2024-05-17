import 'package:freezed_annotation/freezed_annotation.dart';
part 'virtual_keyboard_state.freezed.dart';

@freezed
class VirtualKeyboardState with _$VirtualKeyboardState {
  const factory VirtualKeyboardState({
    required bool ctrl,
    required bool shift,
    required bool alt,
  }) = _VirtualKeyboardState;
}
