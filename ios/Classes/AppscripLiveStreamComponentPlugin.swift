import Flutter
import AVKit
import UIKit

public class AppscripLiveStreamComponentPlugin: NSObject, FlutterPlugin {
  private let externalVideo = ExternalVideoTrackManager()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "appscrip_live_stream_component", binaryMessenger: registrar.messenger())
    let instance = AppscripLiveStreamComponentPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "reactivateAudioSession":
      result(reactivateAudioSession())
    case "heartTapFeedback":
      if Thread.isMainThread {
        playHeartTapFeedback()
      } else {
        DispatchQueue.main.async { self.playHeartTapFeedback() }
      }
      result(nil)
    case "openAppSettings":
      openAppSettings(result: result)
    case "createExternalVideoTrack":
      let args = call.arguments as? [String: Any]
      let width = args?["width"] as? Int ?? 720
      let height = args?["height"] as? Int ?? 1280
      externalVideo.createTrack(width: width, height: height, result: result)
    case "pushExternalVideoFrame":
      let args = call.arguments as? [String: Any]
      guard let data = args?["data"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "pushExternalVideoFrame", message: "data is null", details: nil))
        return
      }
      externalVideo.pushFrame(
        data: data,
        width: args?["width"] as? Int ?? 0,
        height: args?["height"] as? Int ?? 0,
        format: args?["format"] as? String ?? "bgra",
        timestampMs: (args?["timestampMs"] as? NSNumber)?.int64Value ?? 0,
        rotation: args?["rotation"] as? Int ?? 0,
        mirror: args?["mirror"] as? Bool ?? false,
        result: result
      )
    case "disposeExternalVideoTrack":
      externalVideo.dispose(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func openAppSettings(result: @escaping FlutterResult) {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      result(false)
      return
    }
    let open: () -> Void = {
      UIApplication.shared.open(url, options: [:]) { success in
        result(success)
      }
    }
    if Thread.isMainThread {
      open()
    } else {
      DispatchQueue.main.async(execute: open)
    }
  }

  

  // MARK: - Heart / like tap feedback

  /// Native haptic only (no system sound) so feedback works alongside WebRTC / LiveKit.
  private func playHeartTapFeedback() {
    let gen = UIImpactFeedbackGenerator(style: .medium)
    gen.prepare()
    gen.impactOccurred(intensity: 1.0)
  }

  // MARK: - Audio session reactivation

  /// Simulates the exact background→foreground AVAudioSession interruption
  /// cycle that iOS performs natively. WebRTC's RTCAudioSession observes
  /// `interruptionNotification` and:
  ///   • on `.began`  — stops the audio unit
  ///   • on `.ended` + `.shouldResume` — reconfigures (playAndRecord) and
  ///     restarts the audio unit
  /// This fixes the silent-mic / no-incoming-audio bug after viewer→copublisher
  /// promotion, where the session is still stuck in playback-only mode.
  private func reactivateAudioSession() -> Bool {
    let session = AVAudioSession.sharedInstance()

    NSLog("[IsmLiveAudio] category BEFORE reactivation: \(session.category.rawValue) mode: \(session.mode.rawValue)")

    // Phase 1: tell WebRTC an interruption began (stops audio unit)
    NotificationCenter.default.post(
      name: AVAudioSession.interruptionNotification,
      object: session,
      userInfo: [
        AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue
      ]
    )
    NSLog("[IsmLiveAudio] Posted synthetic interruption .began")

    // Phase 2: after a brief pause, ensure correct category then end the
    // interruption so WebRTC reconfigures and restarts its audio unit.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      // Belt-and-suspenders: set the correct category in case LiveKit's
      // audio_management missed the transition.
      do {
        try session.setCategory(
          .playAndRecord,
          mode: .videoChat,
          options: [.defaultToSpeaker, .allowBluetooth]
        )
        try session.setActive(true)
        NSLog("[IsmLiveAudio] Forced category to playAndRecord/videoChat")
      } catch {
        NSLog("[IsmLiveAudio] Category override failed (non-fatal): \(error.localizedDescription)")
      }

      NotificationCenter.default.post(
        name: AVAudioSession.interruptionNotification,
        object: session,
        userInfo: [
          AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue,
          AVAudioSessionInterruptionOptionKey: AVAudioSession.InterruptionOptions.shouldResume.rawValue
        ]
      )
      NSLog("[IsmLiveAudio] Posted synthetic interruption .ended (shouldResume) — category NOW: \(session.category.rawValue)")
    }

    return true
  }


}