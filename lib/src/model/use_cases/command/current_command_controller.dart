import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/entities/command/command_template.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/command/command_template_controller.dart';

import '../../entities/command/command_template_part.dart';

part 'current_command_controller.g.dart';

@riverpod
class CurrentCommandTemplateController
    extends _$CurrentCommandTemplateController {
  @override
  CommandTemplate? build() {
    return ref.watch(commandTemplateListProvider).when(
          data: (loadedCommandTemplates) => loadedCommandTemplates.first,
          loading: () => null,
          error: (error, _) => null,
        );
  }

  void update(CommandTemplate newState) {
    ref.watch(commandTemplateListProvider).maybeWhen(
          data: (commandTemplateList) {
            if (!commandTemplateList.contains(newState)) {
              return;
            }
            state = newState;
          },
          orElse: () {},
        );
  }
}

@riverpod
class CurrentCommandParts extends _$CurrentCommandParts {
  @override
  List<CommandTemplatePart> build(CommandTemplate commandTemplate) {
    return <CommandTemplatePart>[];
  }

  void add(CommandTemplatePart part) {
    ref.watch(commandTemplateUsedPartsProvider(commandTemplate)).maybeWhen(
          data: (commandTemplateUsedParts) {
            if (!commandTemplateUsedParts.contains(part)) {
              return;
            }
            state = [...state, part];
          },
          orElse: () {},
        );
  }

  void remove(CommandTemplatePart part) {
    state = state.where((element) => element != part).toList();
  }
}

@riverpod
class CommandBuildController extends _$CommandBuildController {
  @override
  String? build() {
    final currentCommandTemplate =
        ref.watch(currentCommandTemplateControllerProvider);
    if (currentCommandTemplate == null) {
      return null;
    }
    final currentCommandParts =
        ref.watch(currentCommandPartsProvider(currentCommandTemplate));

    final formerPart = currentCommandTemplate.command.split('\\0').first;
    final latterPart = currentCommandTemplate.command.split('\\0').last;
    final builtCommand =
        '$formerPart${currentCommandParts.map((e) => e.command).join()}$latterPart';
    return builtCommand;
  }
}
