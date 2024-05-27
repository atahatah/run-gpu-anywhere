import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/entities/command/command_template.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/command/command_template_controller.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/command/current_command_controller.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/terminal_controller.dart';

class InputSuggester extends HookConsumerWidget {
  const InputSuggester({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandTemplates = ref.watch(commandTemplateListProvider);
    return commandTemplates.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
      data: (loadedCommandTemplates) {
        if (loadedCommandTemplates.isEmpty) {
          return const Text('No command templates');
        }
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CommandTemplateDropdownButton(loadedCommandTemplates),
                const CommandBuiltPreview(),
                const CommandTemplateRunButton(),
              ],
            ),
            const CurrentBuiltCommandComponent(),
            CommandTemplatePartComponent(),
          ],
        );
      },
    );
  }
}

class CommandTemplateDropdownButton extends ConsumerWidget {
  const CommandTemplateDropdownButton(this.commandTemplates, {super.key});
  final List<CommandTemplate> commandTemplates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (commandTemplates.isEmpty) {
      return const Text('No command templates');
    }
    if (commandTemplates.length == 1) {
      return Text(commandTemplates.first.name);
    }
    final currentCommandTemplate =
        ref.watch(currentCommandTemplateControllerProvider);
    return DropdownButton(
      value: currentCommandTemplate,
      items: [
        for (final commandTemplate in commandTemplates)
          DropdownMenuItem(
            value: commandTemplate,
            child: Text(commandTemplate.name),
          ),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }
        ref
            .read(currentCommandTemplateControllerProvider.notifier)
            .update(value);
      },
    );
  }
}

class CommandBuiltPreview extends ConsumerWidget {
  const CommandBuiltPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final builtCommand = ref.watch(commandBuildControllerProvider);
    if (builtCommand == null) {
      return const Text('Yet to build');
    }
    return Text(builtCommand);
  }
}

class CommandTemplateRunButton extends ConsumerWidget {
  const CommandTemplateRunButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandBuildController = ref.watch(commandBuildControllerProvider);
    final host = ref.watch(currentHostProvider);
    return host.maybeWhen(
      data: (host) => ElevatedButton(
        onPressed: commandBuildController != null
            ? () {
                ref
                    .read(terminalControllerProvider(host).notifier)
                    .run(commandBuildController);
              }
            : null,
        child: const Text('Run'),
      ),
      orElse: () {
        throw Exception('No host selected');
      },
    );
  }
}

class CurrentBuiltCommandComponent extends ConsumerWidget {
  const CurrentBuiltCommandComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCommandTemplate =
        ref.watch(currentCommandTemplateControllerProvider);
    if (currentCommandTemplate == null) {
      return const Text('No command template selected');
    }

    final currentCommandParts =
        ref.watch(currentCommandPartsProvider(currentCommandTemplate));

    final formerPart = currentCommandTemplate.command.split(r'\0').first;
    final latterPart = currentCommandTemplate.command.split(r'\0').last;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          color: Colors.grey,
          child: Text(formerPart),
        ),
        for (final part in currentCommandParts)
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              color: Colors.blue,
              child: Text(part.command),
            ),
            onTap: () {
              ref
                  .read(
                    currentCommandPartsProvider(currentCommandTemplate)
                        .notifier,
                  )
                  .remove(part);
            },
          ),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          color: Colors.grey,
          child: Text(latterPart),
        ),
      ],
    );
  }
}

class CommandTemplatePartComponent extends ConsumerWidget {
  CommandTemplatePartComponent({super.key});
  final tc = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCommandTemplate =
        ref.watch(currentCommandTemplateControllerProvider);
    if (currentCommandTemplate == null) {
      return const Text('No command template selected');
    }
    final commandTemplatePartList =
        ref.watch(commandTemplateUsedPartsProvider(currentCommandTemplate));
    final currentCommandParts =
        ref.watch(currentCommandPartsProvider(currentCommandTemplate));
    return commandTemplatePartList.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
      data: (loadedCommandTemplateParts) {
        if (loadedCommandTemplateParts.isEmpty) {
          return const Text('No command templates');
        }
        return Column(
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  for (final commandTemplatePart in loadedCommandTemplateParts)
                    if (!currentCommandParts.contains(commandTemplatePart))
                      TextSpan(
                        text: '${commandTemplatePart.command} ',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ref
                                .read(
                                  currentCommandPartsProvider(
                                    currentCommandTemplate,
                                  ).notifier,
                                )
                                .add(commandTemplatePart);
                          },
                      ),
                ],
              ),
            ),
            Row(
              children: [
                const Text('Another part: '),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: tc,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newCommandTemplatePart = await ref
                        .read(
                          commandTemplateUsedPartsProvider(
                            currentCommandTemplate,
                          ).notifier,
                        )
                        .touch(tc.text);
                    if (newCommandTemplatePart == null) {
                      return;
                    }
                    ref
                        .read(
                          currentCommandPartsProvider(currentCommandTemplate)
                              .notifier,
                        )
                        .add(newCommandTemplatePart);
                  },
                  child: const Text('Use'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
