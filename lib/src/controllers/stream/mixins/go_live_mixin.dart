part of '../stream_controller.dart';

mixin GoLiveMixin {
  IsmLiveStreamController get _controller => Get.find<IsmLiveStreamController>();

  bool get isGoLiveEnabled => _controller.descriptionController.isNotEmpty;

  Future<void> initializationOfGoLive() async {
    await Permission.camera.request();
    _controller.cameraController = CameraController(
      IsmLiveUtility.cameras[1],
      ResolutionPreset.medium,
    );
    _controller.cameraFuture = _controller.cameraController!.initialize();
    _controller.update([IsmGoLiveView.updateId]);
  }
}
