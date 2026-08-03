package com.example.appscrip_live_stream_component.deepar

import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import org.webrtc.JavaI420Buffer
import org.webrtc.PeerConnectionFactory
import org.webrtc.VideoFrame
import org.webrtc.VideoSource
import org.webrtc.VideoTrack
import org.webrtc.MediaStream
import java.util.ArrayList
import java.util.HashMap
import java.util.UUID
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Creates a WebRTC video track backed by app-pushed RGBA/BGRA frames (DeepAR).
 *
 * Frame conversion runs on a background thread; the method-channel call returns
 * immediately so the Flutter UI / platform thread is not blocked (hang fix).
 *
 * ponytail: reflection into flutter_webrtc internals — replace with public
 * CustomVideoSource API when flutter-webrtc PR #2094 merges.
 */
class ExternalVideoTrackManager {
  companion object {
    private const val TAG = "IsmLiveExtVideo"
  }

  private var videoSource: VideoSource? = null
  private var videoTrack: VideoTrack? = null
  private var mediaStream: MediaStream? = null
  private var streamId: String? = null
  private var trackId: String? = null
  private var capturerStarted = false
  private val pushing = AtomicBoolean(false)
  private var webrtcHandler: Any? = null

  private var frameThread: HandlerThread? = null
  private var frameHandler: Handler? = null

  fun createTrack(width: Int, height: Int, result: MethodChannel.Result) {
    try {
      disposeInternal()
      ensureFrameThread()

      val plugin = resolveFlutterWebRtcPlugin()
        ?: throw IllegalStateException("FlutterWebRTCPlugin not ready")
      val factory = plugin.javaClass
        .getMethod("getPeerConnectionFactory")
        .invoke(plugin) as? PeerConnectionFactory
        ?: throw IllegalStateException("PeerConnectionFactory is null — connect LiveKit first")

      val handler = resolveHandler(plugin)
      webrtcHandler = handler

      val sid = UUID.randomUUID().toString()
      val tid = UUID.randomUUID().toString()

      val source = factory.createVideoSource(/* isScreencast= */ false)
      val track = factory.createVideoTrack(tid, source)
      track.setEnabled(true)
      val stream = factory.createLocalMediaStream(sid)
      stream.addTrack(track)

      source.capturerObserver.onCapturerStarted(true)
      capturerStarted = true

      // Register with flutter_webrtc. Do NOT setVideoProcessor — push frames
      // straight into capturerObserver so they reach the encoder/renderer.
      val localVideoTrackClass = Class.forName("com.cloudwebrtc.webrtc.video.LocalVideoTrack")
      val localVideoTrack = localVideoTrackClass
        .getConstructor(VideoTrack::class.java)
        .newInstance(track)

      handler.javaClass
        .getMethod("putLocalStream", String::class.java, MediaStream::class.java)
        .invoke(handler, sid, stream)
      handler.javaClass
        .getMethod(
          "putLocalTrack",
          String::class.java,
          Class.forName("com.cloudwebrtc.webrtc.LocalTrack"),
        )
        .invoke(handler, tid, localVideoTrack)

      videoSource = source
      videoTrack = track
      mediaStream = stream
      streamId = sid
      trackId = tid

      val videoTrackMap = HashMap<String, Any?>()
      videoTrackMap["id"] = tid
      videoTrackMap["label"] = tid
      videoTrackMap["kind"] = "video"
      videoTrackMap["enabled"] = true
      videoTrackMap["readyState"] = "live"
      videoTrackMap["remote"] = false
      videoTrackMap["settings"] = HashMap<String, Any>()

      val videoTracks = ArrayList<Any>()
      videoTracks.add(videoTrackMap)

      val response = HashMap<String, Any?>()
      response["streamId"] = sid
      response["audioTracks"] = ArrayList<Any>()
      response["videoTracks"] = videoTracks
      Log.d(TAG, "Created external video track $tid on stream $sid (${width}x$height)")
      result.success(response)
    } catch (t: Throwable) {
      Log.e(TAG, "createTrack failed", t)
      disposeInternal()
      result.error("createExternalVideoTrack", t.message, null)
    }
  }

  fun pushFrame(
    data: ByteArray,
    width: Int,
    height: Int,
    format: String,
    timestampMs: Long,
    rotation: Int,
    mirror: Boolean,
    result: MethodChannel.Result,
  ) {
    val source = videoSource
    if (source == null) {
      result.error("pushExternalVideoFrame", "No active external track", null)
      return
    }
    // Ack immediately — never block the platform thread on RGBA→I420.
    result.success(null)

    if (!pushing.compareAndSet(false, true)) {
      return
    }
    val handler = frameHandler
    if (handler == null) {
      pushing.set(false)
      return
    }
    // Copy is already owned by the method-channel buffer; post work off-thread.
    handler.post {
      try {
        val buffer = JavaI420Buffer.allocate(width, height)
        convertToI420(data, width, height, format, mirror, buffer)
        val rot = when (rotation) {
          90, 180, 270 -> rotation
          else -> 0
        }
        val tsNs = if (timestampMs > 0) {
          timestampMs * 1_000_000L
        } else {
          System.nanoTime()
        }
        val frame = VideoFrame(buffer, rot, tsNs)
        source.capturerObserver.onFrameCaptured(frame)
        frame.release()
      } catch (t: Throwable) {
        Log.e(TAG, "pushFrame failed", t)
      } finally {
        pushing.set(false)
      }
    }
  }

  fun dispose(result: MethodChannel.Result) {
    disposeInternal()
    result.success(null)
  }

  private fun ensureFrameThread() {
    if (frameThread != null) return
    frameThread = HandlerThread("IsmLiveExtVideo").also { it.start() }
    frameHandler = Handler(frameThread!!.looper)
  }

  private fun stopFrameThread() {
    frameThread?.quitSafely()
    try {
      frameThread?.join(500)
    } catch (_: InterruptedException) {
    }
    frameThread = null
    frameHandler = null
  }

  private fun disposeInternal() {
    try {
      if (capturerStarted) {
        videoSource?.capturerObserver?.onCapturerStopped()
      }
    } catch (_: Throwable) {
    }
    capturerStarted = false
    try {
      videoTrack?.setEnabled(false)
      videoTrack?.dispose()
    } catch (_: Throwable) {
    }
    videoTrack = null
    try {
      videoSource?.dispose()
    } catch (_: Throwable) {
    }
    videoSource = null
    try {
      mediaStream?.dispose()
    } catch (_: Throwable) {
    }
    mediaStream = null

    val handler = webrtcHandler
    val tid = trackId
    val sid = streamId
    if (handler != null && tid != null) {
      try {
        handler.javaClass.getMethod("trackDispose", String::class.java).invoke(handler, tid)
      } catch (_: Throwable) {
      }
    }
    if (handler != null && sid != null) {
      try {
        handler.javaClass.getMethod("streamDispose", String::class.java).invoke(handler, sid)
      } catch (_: Throwable) {
      }
    }
    webrtcHandler = null
    trackId = null
    streamId = null
    stopFrameThread()
  }

  private fun resolveFlutterWebRtcPlugin(): Any? {
    return try {
      val clazz = Class.forName("com.cloudwebrtc.webrtc.FlutterWebRTCPlugin")
      clazz.getField("sharedSingleton").get(null)
    } catch (t: Throwable) {
      Log.e(TAG, "FlutterWebRTCPlugin lookup failed", t)
      null
    }
  }

  private fun resolveHandler(plugin: Any): Any {
    val field = plugin.javaClass.getDeclaredField("methodCallHandler")
    field.isAccessible = true
    return field.get(plugin)
      ?: throw IllegalStateException("methodCallHandler is null")
  }

  private fun convertToI420(
    src: ByteArray,
    width: Int,
    height: Int,
    format: String,
    mirror: Boolean,
    buffer: JavaI420Buffer,
  ) {
    val isBgra = format.equals("bgra", ignoreCase = true)
    val y = buffer.dataY
    val u = buffer.dataU
    val v = buffer.dataV
    val yStride = buffer.strideY
    val uStride = buffer.strideU
    val vStride = buffer.strideV

    for (row in 0 until height) {
      val yRow = row * yStride
      for (col in 0 until width) {
        val srcCol = if (mirror) (width - 1 - col) else col
        val srcIndex = (row * width + srcCol) * 4
        val b0 = src[srcIndex].toInt() and 0xff
        val b1 = src[srcIndex + 1].toInt() and 0xff
        val b2 = src[srcIndex + 2].toInt() and 0xff
        val r: Int
        val g: Int
        val b: Int
        if (isBgra) {
          b = b0
          g = b1
          r = b2
        } else {
          r = b0
          g = b1
          b = b2
        }
        val yVal = ((66 * r + 129 * g + 25 * b + 128) shr 8) + 16
        y.put(yRow + col, yVal.coerceIn(0, 255).toByte())
      }
    }

    for (row in 0 until height step 2) {
      val uRow = (row / 2) * uStride
      val vRow = (row / 2) * vStride
      for (col in 0 until width step 2) {
        var rSum = 0
        var gSum = 0
        var bSum = 0
        var count = 0
        for (dy in 0..1) {
          val rr = row + dy
          if (rr >= height) continue
          for (dx in 0..1) {
            val cc = col + dx
            if (cc >= width) continue
            val srcCol = if (mirror) (width - 1 - cc) else cc
            val idx = (rr * width + srcCol) * 4
            val b0 = src[idx].toInt() and 0xff
            val b1 = src[idx + 1].toInt() and 0xff
            val b2 = src[idx + 2].toInt() and 0xff
            if (isBgra) {
              bSum += b0
              gSum += b1
              rSum += b2
            } else {
              rSum += b0
              gSum += b1
              bSum += b2
            }
            count++
          }
        }
        if (count == 0) continue
        val r = rSum / count
        val g = gSum / count
        val b = bSum / count
        val uVal = ((-38 * r - 74 * g + 112 * b + 128) shr 8) + 128
        val vVal = ((112 * r - 94 * g - 18 * b + 128) shr 8) + 128
        u.put(uRow + col / 2, uVal.coerceIn(0, 255).toByte())
        v.put(vRow + col / 2, vVal.coerceIn(0, 255).toByte())
      }
    }
  }
}
