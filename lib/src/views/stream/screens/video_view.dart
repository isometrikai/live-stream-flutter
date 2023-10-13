// import 'package:flutter/material.dart';
// import 'package:livekit_client/livekit_client.dart';

// class VideoView extends StatefulWidget {
//   const VideoView(this.participant, {super.key});
//   final Participant participant;

//   @override
//   State<StatefulWidget> createState() => _VideoViewState();
// }

// class _VideoViewState extends State<VideoView> {
//   TrackPublication? videoPub;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   widget.participant.addListener(_onParticipantChanged);
//   //   // trigger initial change
//   //   _onParticipantChanged();
//   // }

//   // @override
//   // void dispose() {
//   //   widget.participant.removeListener(_onParticipantChanged);
//   //   super.dispose();
//   // }

//   // @override
//   // void didUpdateWidget(covariant VideoView oldWidget) {
//   //   oldWidget.participant.removeListener(_onParticipantChanged);
//   //   widget.participant.addListener(_onParticipantChanged);
//   //   _onParticipantChanged();
//   //   super.didUpdateWidget(oldWidget);
//   // }

//   // void _onParticipantChanged() {
//   //   var subscribedVideos = widget.participant.videoTracks.where((pub) =>
//   //       pub.kind == TrackType.VIDEO && !pub.isScreenShare && pub.subscribed);

//   //   setState(() {
//   //     if (subscribedVideos.isNotEmpty) {
//   //       var videoPub = subscribedVideos.first;
//   //       // when muted, show placeholder
//   //       if (!videoPub.muted) {
//   //         this.videoPub = videoPub;
//   //         return;
//   //       }
//   //     }
//   //     videoPub = null;
//   //   });
//   // }

//   // @override
//   // Widget build(BuildContext context) {
//   //
//   //   if (videoPub != null) {
//   //     return VideoTrackRenderer(videoPub.track as VideoTrack);
//   //   } else {
//   //     return Container(
//   //       color: Colors.grey,
//   //     );
//   //   }
//   // }
// }
