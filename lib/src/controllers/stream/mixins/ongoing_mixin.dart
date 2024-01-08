part of '../stream_controller.dart';

mixin StreamOngoingMixin {
  IsmLiveStreamController get _controller => Get.find();

  String controlIcon(IsmLiveStreamOption option) {
    switch (option) {
      case IsmLiveStreamOption.gift:
      case IsmLiveStreamOption.multiLive:
      case IsmLiveStreamOption.share:
      case IsmLiveStreamOption.members:
      case IsmLiveStreamOption.favourite:
      case IsmLiveStreamOption.settings:
      case IsmLiveStreamOption.rotateCamera:
      case IsmLiveStreamOption.vs:
        return option.icon;
      case IsmLiveStreamOption.speaker:
        if (_controller.speakerOn) {
          return IsmLiveAssetConstants.speakerOn;
        }
        return IsmLiveAssetConstants.speakerOff;
    }
  }

  Future<void> toggleSpeaker({Room? room, bool? value}) async {
    _controller.speakerOn = value ?? !_controller.speakerOn;

    _controller.speakerOn
        ? await room?.participants.values.first.audioTracks.first.enable()
        : await room?.participants.values.first.audioTracks.first.disable();

    // TODO: speaker change not working, fix this
    //if above code is not working in iso use this
    // await Hardware.instance.setPreferSpeakerOutput(_controller.speakerOn);
    // await Hardware.instance.setSpeakerphoneOn(_controller.speakerOn);
  }

  Future onOptionTap(
    IsmLiveStreamOption option, {
    LocalParticipant? participant,
    Room? room,
  }) async {
    switch (option) {
      case IsmLiveStreamOption.gift:
      case IsmLiveStreamOption.multiLive:
      case IsmLiveStreamOption.share:
      case IsmLiveStreamOption.members:
      case IsmLiveStreamOption.favourite:
      case IsmLiveStreamOption.settings:
      case IsmLiveStreamOption.vs:
        break;
      case IsmLiveStreamOption.rotateCamera:
        _controller.toggleCamera(participant);
        break;
      case IsmLiveStreamOption.speaker:
        await toggleSpeaker(room: room);
        break;
    }
  }
}
