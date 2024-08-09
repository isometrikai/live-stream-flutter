import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class IsmLiveCallingController extends GetxController {
  IsmLiveCallingController(this._viewModel);
  final IsmLiveCallingViewModel _viewModel;

  List<IsmLiveParticipantTrack> participantTracks = [];

  double positionX = 20;
  double positionY = 20;

  CameraPosition position = CameraPosition.front;

  final RxBool _showFullScreen = false.obs;
  bool get showFullScreen => _showFullScreen.value;
  set showFullScreen(bool value) => _showFullScreen.value = value;

  // ----------- Functions -----------

  void onClick(int index) {
    var member2 = participantTracks.elementAt(index + 1);
    participantTracks[index + 1] = participantTracks.elementAt(0);
    participantTracks[0] = member2;
    update(['room']);
  }

  void onPan(details) {
    positionX += details.delta.dx;
    positionY += details.delta.dy;
    update(['room']);
  }

  Future<void> setUpListeners(
    EventsListener<RoomEvent> listener,
    Room room,
  ) async =>
      listener
        ..on<RoomDisconnectedEvent>((event) async {
          if (event.reason != null) {
            IsmLiveLog.error('Room disconnected: reason => ${event.reason}');
          }
          Get.back();
        })
        ..on<ParticipantEvent>((event) {
          IsmLiveLog.error('Participant event');

          sortParticipants(room);
        })
        ..on<RoomRecordingStatusChanged>((event) {})
        ..on<LocalTrackPublishedEvent>((_) => sortParticipants(room))
        ..on<LocalTrackUnpublishedEvent>((_) => sortParticipants(room))
        ..on<TrackE2EEStateEvent>(onE2EEStateEvent)
        ..on<ParticipantNameUpdatedEvent>((event) {
          IsmLiveLog(
              'Participant name updated: ${event.participant.identity}, name => ${event.name}');
        })
        ..on<DataReceivedEvent>((event) {
          var decoded = 'Failed to decode';
          try {
            decoded = utf8.decode(event.data);
          } catch (e) {
            IsmLiveLog('$decoded: $e');
          }
        })
        ..on<AudioPlaybackStatusChanged>((event) async {
          if (!room.canPlaybackAudio) {
            IsmLiveLog('Audio playback failed for iOS Safari ..........');
          }
        });

  void onE2EEStateEvent(TrackE2EEStateEvent e2eeState) {
    IsmLiveLog('e2ee state: $e2eeState');
  }

  Future<void> sortParticipants(
    Room room,
  ) async {
    var userMediaTracks = <IsmLiveParticipantTrack>[];

    for (var participant in room.remoteParticipants.values) {
      for (var t in participant.videoTrackPublications) {
        userMediaTracks.add(IsmLiveParticipantTrack(
          participant: participant,
          videoTrack: t.track,
          isScreenShare: false,
        ));
      }
    }
    userMediaTracks.sort((a, b) {
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }

      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      return a.participant.joinedAt.millisecondsSinceEpoch -
          b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipantTracks =
        room.localParticipant?.videoTrackPublications;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        userMediaTracks.add(IsmLiveParticipantTrack(
          participant: room.localParticipant!,
          videoTrack: t.track,
          isScreenShare: false,
        ));
      }
    }

    participantTracks = [...userMediaTracks];
    update(['room']);
  }

  Future<void> askPublish(Room room, bool audioCall) async {
    try {
      if (!audioCall) {
        await room.localParticipant?.setCameraEnabled(true);
      } else {
        await room.localParticipant?.setCameraEnabled(false);
      }
    } catch (error) {
      IsmLiveLog('could not publish video: $error');
    }
    try {
      await room.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      IsmLiveLog('could not publish audio: $error');
    }
  }

  void onRoomDidUpdate(Room room) {
    sortParticipants(room);
  }

  Future<void> onTapDisconnect(room, meetingId) async {
    var res = await stopMeeting(
      isLoading: true,
      meetingId: meetingId,
    );

    if (res) {
      await room.disconnect();
    }
  }

  /// The function `stopMeeting` takes in parameters `isLoading` and `meetingId` and calls
  /// `_viewModel.stopMeeting` with those parameters.
  ///
  /// Args:
  ///   isLoading (bool): The `isLoading` parameter is a boolean value that indicates whether the meeting
  /// is currently loading or not.
  ///   meetingId (String): The `meetingId` parameter is a required `String` parameter that represents the
  /// unique identifier of the meeting that you want to stop.
  Future<bool> stopMeeting({
    required bool isLoading,
    required String meetingId,
  }) =>
      _viewModel.stopMeeting(
        isLoading: isLoading,
        meetingId: meetingId,
      );

  void disableAudio(LocalParticipant participant) async {
    await participant.setMicrophoneEnabled(false);
  }

  Future<void> enableAudio(LocalParticipant participant) async {
    await participant.setMicrophoneEnabled(true);
  }

  void disableVideo(LocalParticipant participant) async {
    await participant.setCameraEnabled(false);
  }

  void enableVideo(LocalParticipant participant) async {
    await participant.setCameraEnabled(true);
  }

  void toggleCamera(LocalParticipant participant) async {
    final track = participant.videoTrackPublications.firstOrNull?.track;
    if (track == null) return;

    try {
      final newPosition = position.switched();
      await track.setCameraPosition(newPosition);
      position = newPosition;
      update();
    } catch (error) {
      IsmLiveLog('could not restart track: $error');
      return;
    }
  }
}
