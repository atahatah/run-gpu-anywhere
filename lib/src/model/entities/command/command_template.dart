import 'package:freezed_annotation/freezed_annotation.dart';

part 'command_template.freezed.dart';
part 'command_template.g.dart';

@freezed
class CommandTemplate with _$CommandTemplate {
  const factory CommandTemplate({
    required String name,
    required String command,
  }) = _CommandTemplate;

  factory CommandTemplate.fromJson(Map<String, dynamic> json) =>
      _$CommandTemplateFromJson(json);
}
