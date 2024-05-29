import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveUserRole {
  IsmLiveUserRole._(
    List<IsmLivePermission> permissions,
  ) : _permissions = permissions;

  factory IsmLiveUserRole.host() => IsmLiveUserRole._([IsmLivePermission.host]);

  factory IsmLiveUserRole.viewer() =>
      IsmLiveUserRole._([IsmLivePermission.viewer]);

  final List<IsmLivePermission> _permissions;

  bool get isHost => _permissions.any((e) => e.isHost);

  bool get isViewer => _permissions.any((e) => e.isViewer);

  bool get isModerator => _permissions.any((e) => e.isModerator);

  bool get isCopublisher => _permissions.any((e) => e.isCopublisher);

  bool get isPkGuest => _permissions.any((e) => e.isPkGuest);

  void makePkGuest() {
    _permissions.add(IsmLivePermission.pkGuest);
  }

  void removePkGuest() {
    _permissions.remove(IsmLivePermission.pkGuest);
  }

  void makeModerator() {
    if (isHost) {
      return;
    }
    _permissions.add(IsmLivePermission.moderator);
  }

  void leaveModeration() {
    _permissions.remove(IsmLivePermission.moderator);
  }

  void makeCopublisher() {
    if (isHost) {
      _permissions.add(IsmLivePermission.copublisher);
      return;
    }
    _permissions.remove(IsmLivePermission.viewer);
    _permissions.add(IsmLivePermission.copublisher);
  }

  void leaveCopublishing() {
    if (isHost && isCopublisher) {
      _permissions.remove(IsmLivePermission.copublisher);
      return;
    }
    _permissions.remove(IsmLivePermission.copublisher);
    _permissions.add(IsmLivePermission.viewer);
  }

  @override
  String toString() => 'IsmLiveUserRole(permission: $_permissions)';

  @override
  bool operator ==(covariant IsmLiveUserRole other) {
    if (identical(this, other)) return true;

    return listEquals(other._permissions, _permissions);
  }

  @override
  int get hashCode => _permissions.hashCode;
}

class IsmLivePkStages {
  IsmLivePkStages._(
    List<IsmLiveStages> stages,
  ) : _stages = stages;

  factory IsmLivePkStages.isPk() => IsmLivePkStages._([IsmLiveStages.pk]);
  final List<IsmLiveStages> _stages;

  bool get isPk => _stages.any((e) => e.isPk);

  bool get isPkStart => _stages.any((e) => e.isPkStart);

  bool get isPkStop => _stages.any((e) => e.isPkStop);

  void makePk() {
    _stages.add(IsmLiveStages.pk);
  }

  void removePk() {
    _stages.remove(IsmLiveStages.pk);
  }

  void makePkStart() {
    _stages.add(IsmLiveStages.pkStart);
  }

  void removePkStart() {
    _stages.remove(IsmLiveStages.pkStart);
  }

  void makePkStop() {
    _stages.add(IsmLiveStages.pkStop);
  }

  void removePkStop() {
    _stages.remove(IsmLiveStages.pkStop);
  }

  @override
  String toString() => 'IsmLivePkStages(_stages: $_stages)';

  @override
  bool operator ==(covariant IsmLivePkStages other) {
    if (identical(this, other)) return true;

    return listEquals(other._stages, _stages);
  }

  @override
  int get hashCode => _stages.hashCode;
}
