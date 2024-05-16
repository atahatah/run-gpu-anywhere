import 'package:freezed_annotation/freezed_annotation.dart';
part 'run_result.freezed.dart';
part 'run_result.g.dart';

@freezed
class RunResult with _$RunResult {
  const factory RunResult({
    required String name,
  }) = _RunResult;

  factory RunResult.fromJson(Map<String, dynamic> json) =>
      _$RunResultFromJson(json);
}
