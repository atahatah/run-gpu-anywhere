import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/entities/command/command_template.dart';
import 'package:run_gpu_anywhere/src/model/entities/command/command_template_part.dart';

part 'command_template_controller.g.dart';

const t = CommandTemplate(name: 'ls', command: 'ls \\0 \$HOME', split: ' ');

@riverpod
class CommandTemplateList extends _$CommandTemplateList {
  @override
  Future<List<CommandTemplate>> build() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const [
      CommandTemplate(name: 'temp1', command: 'command1', split: ' '),
      CommandTemplate(name: 'temp2', command: 'command2', split: ' '),
      CommandTemplate(name: 'temp3', command: 'command3', split: ' '),
      t,
    ];
  }
}

@riverpod
class CommandTemplateUsedParts extends _$CommandTemplateUsedParts {
  @override
  Future<List<CommandTemplatePart>> build(
    CommandTemplate commandTemplate,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (commandTemplate == t) {
      return const [
        CommandTemplatePart(command: '-a', position: 0),
        CommandTemplatePart(command: '-l', position: 0),
        CommandTemplatePart(command: '-h', position: 0),
      ];
    }
    return const [
      CommandTemplatePart(command: 'part1', position: 0),
      CommandTemplatePart(command: 'part2', position: 0),
      CommandTemplatePart(command: 'part3', position: 0),
    ];
  }
}
