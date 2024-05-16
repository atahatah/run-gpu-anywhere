import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/host_list/add_host_page.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/host_list/host_list_page.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/main/main_page.dart';
import 'package:run_gpu_anywhere/src/presentation/pages/terminal/terminal_page.dart';

part 'router.g.dart';

@riverpod
GlobalKey<NavigatorState> navigatorKey(NavigatorKeyRef ref) {
  return GlobalKey<NavigatorState>();
}

@riverpod
GoRouter router(RouterRef ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: TerminalPage.pagePath,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: MainPage.pagePath,
        name: MainPage.pageName,
        pageBuilder: (_, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const MainPage(),
          );
        },
      ),
      GoRoute(
        path: TerminalPage.pagePath,
        name: TerminalPage.pageName,
        pageBuilder: (_, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const TerminalPage(),
          );
        },
      ),
      GoRoute(
        path: HostListPage.pagePath,
        name: HostListPage.pageName,
        pageBuilder: (_, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const HostListPage(),
          );
        },
      ),
      GoRoute(
        path: AddHostPage.pagePath,
        name: AddHostPage.pageName,
        pageBuilder: (_, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: AddHostPage(),
          );
        },
      ),
    ],
  );
}
