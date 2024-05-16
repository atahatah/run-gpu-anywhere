import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences.g.dart';

@riverpod
class SharedPreferencesStorage extends _$SharedPreferencesStorage {
  @override
  Future<SharedPreferences> build() async {
    return SharedPreferences.getInstance();
  }
}
