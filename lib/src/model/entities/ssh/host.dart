import 'package:freezed_annotation/freezed_annotation.dart';
part 'host.freezed.dart';
part 'host.g.dart';

@freezed
class Host with _$Host {
  const factory Host({
    required String name,
    required String ip,
    required int port,
    required String userName,
    required String password,
    required String lang,
  }) = _Host;

  factory Host.fromJson(Map<String, dynamic> json) => _$HostFromJson(json);
}
