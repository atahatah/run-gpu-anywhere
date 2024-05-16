import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/src/model/entities/ssh/host.dart';
import 'package:run_gpu_anywhere/src/model/use_cases/terminal/ssh_host_controller.dart';

class AddHostPage extends ConsumerWidget {
  AddHostPage({super.key});

  static String get pageName => 'AddHostPage';
  static String get pagePath => '/hosts_list/add_host';

  final name = TextEditingController();
  final ip = TextEditingController();
  final port = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Host'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Name:'),
              TextField(controller: name),
              const Text('IP Address:'),
              TextField(
                controller: ip,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const Text('Port:'),
              TextField(controller: port, keyboardType: TextInputType.number),
              const Text('User Name:'),
              TextField(
                controller: userName,
              ),
              const Text('Password:'),
              TextField(controller: password, obscureText: true),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () async {
                  final newHost = Host(
                    name: name.text,
                    ip: ip.text,
                    port: int.parse(port.text),
                    userName: userName.text,
                    password: password.text,
                  );
                  final sshHostListController =
                      ref.read(sSHHostListProvider.notifier);
                  await sshHostListController.addHost(newHost);
                  if (!context.mounted) {
                    return;
                  }
                  GoRouter.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
