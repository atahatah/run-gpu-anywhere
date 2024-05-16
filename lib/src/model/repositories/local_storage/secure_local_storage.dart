import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_local_storage.g.dart';

@riverpod
class SecureLocalStorage extends _$SecureLocalStorage {
  @override
  FlutterSecureStorage build() {
    return const FlutterSecureStorage();
  }

  Future<String?> read(String key) async {
    return state.read(key: key);
  }

  Future<void> write(String key, String value) async {
    await state.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    await state.delete(key: key);
  }
}
