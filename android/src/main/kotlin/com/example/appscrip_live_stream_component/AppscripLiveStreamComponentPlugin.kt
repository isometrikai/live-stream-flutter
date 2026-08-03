package com.example.appscrip_live_stream_component

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import com.example.appscrip_live_stream_component.deepar.ExternalVideoTrackManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AppscripLiveStreamComponentPlugin */
class AppscripLiveStreamComponentPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var appContext: Context
  private val externalVideo = ExternalVideoTrackManager()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    appContext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "appscrip_live_stream_component")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "heartTapFeedback" -> {
        performHeartTapFeedback(result)
      }
      "openAppSettings" -> {
        openAppSettings(result)
      }
      "createExternalVideoTrack" -> {
        val width = call.argument<Int>("width") ?: 720
        val height = call.argument<Int>("height") ?: 1280
        externalVideo.createTrack(width, height, result)
      }
      "pushExternalVideoFrame" -> {
        val data = call.argument<ByteArray>("data")
        if (data == null) {
          result.error("pushExternalVideoFrame", "data is null", null)
          return
        }
        externalVideo.pushFrame(
          data = data,
          width = call.argument<Int>("width") ?: 0,
          height = call.argument<Int>("height") ?: 0,
          format = call.argument<String>("format") ?: "rgba",
          timestampMs = (call.argument<Number>("timestampMs")?.toLong()) ?: 0L,
          rotation = call.argument<Int>("rotation") ?: 0,
          mirror = call.argument<Boolean>("mirror") ?: false,
          result = result,
        )
      }
      "disposeExternalVideoTrack" -> externalVideo.dispose(result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    externalVideo.dispose(object : Result {
      override fun success(result: Any?) {}
      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
      override fun notImplemented() {}
    })
    channel.setMethodCallHandler(null)
  }

  private fun openAppSettings(result: Result) {
    try {
      val intent =
              Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", appContext.packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
              }
      appContext.startActivity(intent)
      result.success(true)
    } catch (_: Throwable) {
      result.success(false)
    }
  }

  @Suppress("DEPRECATION")
  private fun getVibrator(context: Context): Vibrator? {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
      vm?.defaultVibrator
    } else {
      context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    }
  }

  private fun performHeartTapFeedback(result: Result) {
    try {
      val vibrator = getVibrator(appContext)
      if (vibrator != null && vibrator.hasVibrator()) {
        vibrateHeartTap(vibrator)
      }
    } catch (_: Throwable) {
      // Never crash on vibration: NoSuchMethodError on some API 31+ OEM images, etc.
    }

    result.success(null)
  }

  /**
   * Medium-strength UI tap: [EFFECT_DOUBLE_CLICK] on API 30+, moderate one-shots below.
   *
   * Uses [Vibrator.vibrate] single-arg overload when the API 31+ two-arg overload is missing (some
   * devices report SDK 31+ but throw [NoSuchMethodError] for vibrate+attributes).
   */
  private fun vibrateHeartTap(vibrator: Vibrator) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      @Suppress("DEPRECATION") vibrator.vibrate(45)
      return
    }

    val effect: VibrationEffect =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
              VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK)
            } else {
              val amplitude =
                      if (vibrator.hasAmplitudeControl()) {
                        160
                      } else {
                        VibrationEffect.DEFAULT_AMPLITUDE
                      }
              VibrationEffect.createOneShot(50, amplitude)
            }

    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        try {
          val attrs =
                  VibrationAttributes.Builder().setUsage(VibrationAttributes.USAGE_TOUCH).build()
          vibrator.vibrate(effect, attrs)
        } catch (_: Throwable) {
          vibrator.vibrate(effect)
        }
      } else {
        vibrator.vibrate(effect)
      }
    } catch (_: Throwable) {
      try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          vibrator.vibrate(VibrationEffect.createOneShot(55, 160))
        } else {
          @Suppress("DEPRECATION") vibrator.vibrate(50)
        }
      } catch (_: Throwable) {}
    }
  }
}
