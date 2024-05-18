import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/command/command_template_controller.dart';
import 'package:run_gpu_anywhere/src/presentation/components/bottom_navigation_bar.dart';

import 'add_command_template.dart';

class CommandTemplateListPage extends ConsumerWidget {
  const CommandTemplateListPage({super.key});

  static const pageName = 'Command Templates';
  static const pagePath = '/command_template_list';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandTemplates = ref.watch(commandTemplateListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Command Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              GoRouter.of(context).push(AddCommandTemplatePage.pagePath);
            },
          ),
        ],
      ),
      bottomNavigationBar: const MyBottomNavigationBar(),
      body: commandTemplates.when(
        error: (error, stackTrace) => Text('Error: $error'),
        loading: () => const CircularProgressIndicator(),
        data: (commandTemplates) {
          if (commandTemplates.isEmpty) {
            return const Text('No command templates');
          }
          return ListView.builder(
            itemCount: commandTemplates.length,
            itemBuilder: (context, index) {
              final commandTemplate = commandTemplates[index];
              return ListTile(
                title: Text(commandTemplate.name),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
