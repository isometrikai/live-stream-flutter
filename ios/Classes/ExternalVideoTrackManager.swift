import Foundation
import Flutter
import WebRTC

/// Creates a WebRTC video track backed by app-pushed BGRA/RGBA frames (DeepAR).
///
/// Registers with FlutterWebRTCPlugin.localTracks / localStreams so LiveKit can
/// publish the track normally.
final class ExternalVideoTrackManager {
  private var videoSource: RTCVideoSource?
  private var videoTrack: RTCVideoTrack?
  private var mediaStream: RTCMediaStream?
  private var streamId: String?
  private var trackId: String?
  private var pushing = false

  func createTrack(width: Int, height: Int, result: @escaping FlutterResult) {
    disposeInternal()

    guard let plugin = FlutterWebRTCPlugin.sharedSingleton(),
          let factory = plugin.peerConnectionFactory else {
      result(
        FlutterError(
          code: "createExternalVideoTrack",
          message: "FlutterWebRTCPlugin / PeerConnectionFactory not ready",
          details: nil
        )
      )
      return
    }

    let sid = UUID().uuidString
    let tid = UUID().uuidString
    let source = factory.videoSource()
    let track = factory.videoTrack(with: source, trackId: tid)
    track.isEnabled = true
    let stream = factory.mediaStream(withStreamId: sid)
    stream.addVideoTrack(track)

    let localVideoTrack = LocalVideoTrack(track: track)
    plugin.localTracks?[tid] = localVideoTrack
    if plugin.localStreams == nil {
      plugin.localStreams = NSMutableDictionary()
    }
    plugin.localStreams?[sid] = stream

    videoSource = source
    videoTrack = track
    mediaStream = stream
    streamId = sid
    trackId = tid

    let videoTrackMap: [String: Any] = [
      "id": tid,
      "label": tid,
      "kind": "video",
      "enabled": true,
      "readyState": "live",
      "remote": false,
      "settings": [String: Any](),
    ]

    result([
      "streamId": sid,
      "audioTracks": [Any](),
      "videoTracks": [videoTrackMap],
    ])
  }

  func pushFrame(
    data: FlutterStandardTypedData,
    width: Int,
    height: Int,
    format: String,
    timestampMs: Int64,
    rotation: Int,
    mirror: Bool,
    result: @escaping FlutterResult
  ) {
    guard videoSource != nil else {
      result(
        FlutterError(
          code: "pushExternalVideoFrame",
          message: "No active external track",
          details: nil
        )
      )
      return
    }
    if pushing {
      result(nil)
      return
    }
    // Ack immediately so the platform thread is not blocked on conversion.
    result(nil)
    pushing = true

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      defer { self?.pushing = false }
      guard let self = self, let source = self.videoSource else { return }

      let bytes = [UInt8](data.data)
      guard bytes.count >= width * height * 4 else { return }

      var bgra = [UInt8](repeating: 0, count: width * height * 4)
      let isRgba = format.lowercased() == "rgba"
      for row in 0..<height {
        for col in 0..<width {
          let srcCol = mirror ? (width - 1 - col) : col
          let srcIndex = (row * width + srcCol) * 4
          let dstIndex = (row * width + col) * 4
          if isRgba {
            bgra[dstIndex] = bytes[srcIndex + 2]
            bgra[dstIndex + 1] = bytes[srcIndex + 1]
            bgra[dstIndex + 2] = bytes[srcIndex]
            bgra[dstIndex + 3] = bytes[srcIndex + 3]
          } else {
            bgra[dstIndex] = bytes[srcIndex]
            bgra[dstIndex + 1] = bytes[srcIndex + 1]
            bgra[dstIndex + 2] = bytes[srcIndex + 2]
            bgra[dstIndex + 3] = bytes[srcIndex + 3]
          }
        }
      }

      var pixelBuffer: CVPixelBuffer?
      let attrs: [CFString: Any] = [
        kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary
      ]
      let status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        kCVPixelFormatType_32BGRA,
        attrs as CFDictionary,
        &pixelBuffer
      )
      guard status == kCVReturnSuccess, let pb = pixelBuffer else { return }

      CVPixelBufferLockBaseAddress(pb, [])
      if let base = CVPixelBufferGetBaseAddress(pb) {
        let stride = CVPixelBufferGetBytesPerRow(pb)
        bgra.withUnsafeBytes { raw in
          guard let src = raw.baseAddress else { return }
          for row in 0..<height {
            memcpy(
              base.advanced(by: row * stride),
              src.advanced(by: row * width * 4),
              width * 4
            )
          }
        }
      }
      CVPixelBufferUnlockBaseAddress(pb, [])

      let buffer = RTCCVPixelBuffer(pixelBuffer: pb)
      let rot: RTCVideoRotation
      switch rotation {
      case 90: rot = ._90
      case 180: rot = ._180
      case 270: rot = ._270
      default: rot = ._0
      }
      let tsNs = timestampMs > 0 ? timestampMs * 1_000_000 : Int64(Date().timeIntervalSince1970 * 1_000_000_000)
      let frame = RTCVideoFrame(buffer: buffer, rotation: rot, timeStampNs: tsNs)
      source.capturer(RTCVideoCapturer(), didCapture: frame)
    }
  }

  func dispose(result: @escaping FlutterResult) {
    disposeInternal()
    result(nil)
  }

  private func disposeInternal() {
    if let plugin = FlutterWebRTCPlugin.sharedSingleton() {
      if let tid = trackId {
        plugin.localTracks?.removeObject(forKey: tid)
      }
      if let sid = streamId {
        plugin.localStreams?.removeObject(forKey: sid)
      }
    }
    videoTrack?.isEnabled = false
    videoTrack = nil
    videoSource = nil
    mediaStream = nil
    trackId = nil
    streamId = nil
  }
}
