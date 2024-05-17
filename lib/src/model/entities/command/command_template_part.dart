import 'package:freezed_annotation/freezed_annotation.dart';

part 'command_template_part.freezed.dart';
part 'command_template_part.g.dart';

@freezed
class CommandTemplatePart with _$CommandTemplatePart {
  const factory CommandTemplatePart({
    required String command,
    required int position,
  }) = _CommandTemplatePart;

  factory CommandTemplatePart.fromJson(Map<String, dynamic> json) =>
      _$CommandTemplatePartFromJson(json);
}
