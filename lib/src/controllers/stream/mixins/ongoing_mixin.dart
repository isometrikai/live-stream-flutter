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

  Future<void> toggleSpeaker([bool? value]) async {
    _controller.speakerOn = value ?? !_controller.speakerOn;

    // TODO: speaker change not working, fix this
    await Hardware.instance.setPreferSpeakerOutput(_controller.speakerOn);
  }

  Future onOptionTap(
    IsmLiveStreamOption option, {
    LocalParticipant? participant,
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
        await toggleSpeaker();
        break;
    }
  }
}
