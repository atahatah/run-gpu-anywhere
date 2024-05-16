import 'package:freezed_annotation/freezed_annotation.dart';
part 'host.freezed.dart';
part 'host.g.dart';

@freezed
class Host with _$Host {
  const factory Host({
    required String name,
  }) = _Host;

  factory Host.fromJson(Map<String, dynamic> json) => _$HostFromJson(json);
}
