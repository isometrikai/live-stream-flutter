import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class RoomPage extends StatefulWidget {
  RoomPage({
    Key? key,
  }) : super(key: key);
  final Room room = Get.arguments['room'];
  final EventsListener<RoomEvent> listener = Get.arguments['listener'];

  @override
  State<StatefulWidget> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<ParticipantTrack> participantTracks = [];
  EventsListener<RoomEvent> get _listener => widget.listener;
  bool get fastConnection => widget.room.engine.fastConnectOptions != null;
  @override
  void initState() {
    super.initState();
    widget.room.addListener(_onRoomDidUpdate);
    _setUpListeners();

    _sortParticipants();

    WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
      if (!fastConnection) {
        _askPublish();
      }
    });

    if (lkPlatformIsMobile()) {
      Hardware.instance.setSpeakerphoneOn(true);
    }
  }

  @override
  void dispose() {
    (() async {
      widget.room.removeListener(_onRoomDidUpdate);
      await _listener.dispose();
      await widget.room.dispose();
    })();
    super.dispose();
  }

  void _setUpListeners() => _listener
    ..on<RoomDisconnectedEvent>((event) async {
      if (event.reason != null) {
        log('Room disconnected: reason => ${event.reason}');
      }
      WidgetsBindingCompatible.instance
          ?.addPostFrameCallback((timeStamp) => Navigator.pop(context));
    })
    ..on<ParticipantEvent>((event) {
      log('Participant event');

      _sortParticipants();
    })
    ..on<RoomRecordingStatusChanged>((event) {})
    ..on<LocalTrackPublishedEvent>((_) => _sortParticipants())
    ..on<LocalTrackUnpublishedEvent>((_) => _sortParticipants())
    ..on<TrackE2EEStateEvent>(_onE2EEStateEvent)
    ..on<ParticipantNameUpdatedEvent>((event) {
      log('Participant name updated: ${event.participant.identity}, name => ${event.name}');
    })
    ..on<DataReceivedEvent>((event) {
      var decoded = 'Failed to decode';
      try {
        decoded = utf8.decode(event.data);
      } catch (_) {
        log('Failed to decode: $_');
      }
    })
    ..on<AudioPlaybackStatusChanged>((event) async {
      if (!widget.room.canPlaybackAudio) {
        log('Audio playback failed for iOS Safari ..........');
      }
    });

  void _askPublish() async {
    try {
      await widget.room.localParticipant?.setCameraEnabled(true);
    } catch (error) {
      log('could not publish video: $error');
    }
    try {
      await widget.room.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      log('could not publish audio: $error');
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _onE2EEStateEvent(TrackE2EEStateEvent e2eeState) {
    log('e2ee state: $e2eeState');
  }

  void _sortParticipants() {
    var userMediaTracks = <ParticipantTrack>[];
    var screenTracks = <ParticipantTrack>[];
    for (var participant in widget.room.participants.values) {
      for (var t in participant.videoTracks) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: true,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: false,
          ));
        }
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

    final localParticipantTracks = widget.room.localParticipant?.videoTracks;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: widget.room.localParticipant!,
            videoTrack: t.track,
            isScreenShare: true,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(
            participant: widget.room.localParticipant!,
            videoTrack: t.track,
            isScreenShare: false,
          ));
        }
      }
    }
    setState(() {
      participantTracks = [...screenTracks, ...userMediaTracks];
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              participantTracks.isNotEmpty
                  ? ParticipantWidget.widgetFor(participantTracks.first,
                      showStatsLayer: false)
                  : const NoVideoWidget(),
              Positioned(
                bottom: 20,
                child: widget.room.localParticipant != null
                    ? ControlsWidget(widget.room, widget.room.localParticipant!)
                    : IsmLiveDimens.box0,
              ),
              Positioned(
                  left: 10,
                  right: 10,
                  top: 20,
                  child: SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: math.max(0, participantTracks.length - 1),
                      itemBuilder: (BuildContext context, int index) =>
                          SizedBox(
                        width: 180,
                        height: 120,
                        child: ParticipantWidget.widgetFor(
                            participantTracks[index + 1]),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      );
}
