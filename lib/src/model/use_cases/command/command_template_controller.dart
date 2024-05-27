import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/entities/command/command_template.dart';
import 'package:run_gpu_anywhere/src/model/entities/command/command_template_part.dart';

part 'command_template_controller.g.dart';

const sample1 =
    CommandTemplate(name: 'ls', command: 'ls \\0 \$HOME', split: ' ');
const sample2 =
    CommandTemplate(name: 'echo', command: 'echo "\\0"', split: ', ');
const sample3 = CommandTemplate(name: 'ping', command: 'ping \\0', split: ' ');

@Riverpod(keepAlive: true)
class CommandTemplateList extends _$CommandTemplateList {
  @override
  Future<List<CommandTemplate>> build() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const [
      sample1,
      sample2,
      sample3,
    ];
  }

  Future<void> add(CommandTemplate commandTemplate) async {
    state.maybeWhen(
      data: (commandTemplateList) {
        if (commandTemplateList.contains(commandTemplate)) {
          return;
        }
        state = AsyncData([...commandTemplateList, commandTemplate]);
      },
      orElse: () {},
    );
  }

  Future<void> delete(CommandTemplate commandTemplate) async {
    state.maybeWhen(
      data: (commandTemplateList) {
        if (!commandTemplateList.contains(commandTemplate)) {
          return;
        }
        state = AsyncData(
          commandTemplateList
              .where((element) => element != commandTemplate)
              .toList(),
        );
      },
      orElse: () {},
    );
  }
}

@Riverpod(keepAlive: true)
class CommandTemplateUsedParts extends _$CommandTemplateUsedParts {
  @override
  Future<List<CommandTemplatePart>> build(
    CommandTemplate commandTemplate,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (commandTemplate == sample1) {
      return const [
        CommandTemplatePart(command: '-a', position: 0),
        CommandTemplatePart(command: '-l', position: 0),
        CommandTemplatePart(command: '-h', position: 0),
      ];
    }
    if (commandTemplate == sample2) {
      return const [
        CommandTemplatePart(command: 'Hello', position: 0),
        CommandTemplatePart(command: 'new', position: 0),
        CommandTemplatePart(command: 'World', position: 0),
      ];
    }
    if (commandTemplate == sample3) {
      return const [
        CommandTemplatePart(command: 'localhost', position: 0),
        CommandTemplatePart(command: '-c 4', position: 0),
        CommandTemplatePart(command: '-4', position: 0),
        CommandTemplatePart(command: '8.8.8.8', position: 0),
      ];
    }
    return const [];
  }

  Future<CommandTemplatePart?> touch(
    String usedPart, {
    int position = 0,
  }) async {
    return state.maybeWhen(
      data: (commandTemplatePartList) {
        final newCommandTemplatePart =
            CommandTemplatePart(command: usedPart, position: position);
        state = AsyncData(
          [
            newCommandTemplatePart,
            ...commandTemplatePartList
                .skipWhile((part) => part.command == usedPart),
          ],
        );
        return newCommandTemplatePart;
      },
      orElse: () => null,
    );
  }
}
