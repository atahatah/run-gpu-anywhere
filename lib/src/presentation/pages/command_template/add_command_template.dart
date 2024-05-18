import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/model/entities/command/command_template.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/command/command_template_controller.dart';

part 'add_command_template.g.dart';

class AddCommandTemplatePage extends ConsumerWidget {
  AddCommandTemplatePage({super.key});

  static String get pageName => 'AddCommandTemplatePage';
  static String get pagePath => '/add_command_template';

  final name = TextEditingController();
  final formerPart = TextEditingController();
  final latterPart = TextEditingController();
  final split = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandTemplateController =
        ref.read(commandTemplateSampleControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Command Template'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Name:'),
            TextField(controller: name),
            const Text('Former Part:'),
            TextField(
              controller: formerPart,
              onChanged: (value) =>
                  commandTemplateController.formerPart = value,
            ),
            const Text('Latter Part:'),
            TextField(
              controller: latterPart,
              onChanged: (value) =>
                  commandTemplateController.latterPart = value,
            ),
            const Text('Split Character:'),
            TextField(
              controller: split,
              onChanged: (value) => commandTemplateController.split = value,
            ),
            CommandTemplateSampleView(
              formerPart: formerPart,
              split: split,
              latterPart: latterPart,
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(commandTemplateListProvider.notifier).add(
                      CommandTemplate(
                        name: name.text,
                        command: '${formerPart.text}\\0${latterPart.text}',
                        split: split.text,
                      ),
                    );
                GoRouter.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class CommandTemplateSampleView extends ConsumerWidget {
  const CommandTemplateSampleView({
    super.key,
    required this.formerPart,
    required this.split,
    required this.latterPart,
  });

  final TextEditingController formerPart;
  final TextEditingController split;
  final TextEditingController latterPart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sample = ref.watch(commandTemplateSampleControllerProvider);
    return Text('Sample: $sample');
  }
}

@riverpod
class CommandTemplateSampleController
    extends _$CommandTemplateSampleController {
  String _formerPart = '';
  String _latterPart = '';
  String _split = '';

  @override
  String build() {
    return '';
  }

  String get formerPart => _formerPart;
  set formerPart(String value) {
    _formerPart = value;
    update();
  }

  String get latterPart => _latterPart;
  set latterPart(String value) {
    _latterPart = value;
    update();
  }

  String get split => _split;
  set split(String value) {
    _split = value;
    update();
  }

  void update() {
    const part = '__';
    state = '$_formerPart$part$_split$part$_split$part$_split$part$_latterPart';
  }
}
