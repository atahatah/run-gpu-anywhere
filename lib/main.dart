import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:run_gpu_anywhere/app.dart';

void main() async {
  runApp(const ProviderScope(child: App()));
}
