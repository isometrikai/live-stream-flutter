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

  bool get isPk => _permissions.any((e) => e.isPk);

  void makePk() {
    _permissions.add(IsmLivePermission.pk);
  }

  void removePk() {
    _permissions.remove(IsmLivePermission.pk);
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
