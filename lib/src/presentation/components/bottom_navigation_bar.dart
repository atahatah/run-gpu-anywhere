import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/command_template/command_template_list_page.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/host_list/host_list_page.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/terminal/terminal_page.dart';

part 'bottom_navigation_bar.g.dart';

class MyBottomNavigationBar extends ConsumerWidget {
  const MyBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentBottomNavigationBarIndexProvider);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        GoRouter.of(context).go(BottomNavigationBarItems.values[index].path);
        ref
            .read(currentBottomNavigationBarIndexProvider.notifier)
            .update(index);
      },
      items: [
        for (final item in BottomNavigationBarItems.values)
          BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          ),
      ],
    );
  }
}

@riverpod
class CurrentBottomNavigationBarIndex
    extends _$CurrentBottomNavigationBarIndex {
  @override
  int build() {
    return 0;
  }

  void update(int index) {
    if (index < 0 || index >= BottomNavigationBarItems.values.length) {
      return;
    }
    state = index;
  }
}

enum BottomNavigationBarItems {
  home(Icons.terminal, 'Terminal', TerminalPage.pagePath),
  search(Icons.computer, 'Hosts', HostListPage.pagePath),
  favorites(
    Icons.settings_input_component,
    'Templates',
    CommandTemplateListPage.pagePath,
  ),
  ;

  const BottomNavigationBarItems(this.icon, this.label, this.path);

  final IconData icon;
  final String label;
  final String path;
}
