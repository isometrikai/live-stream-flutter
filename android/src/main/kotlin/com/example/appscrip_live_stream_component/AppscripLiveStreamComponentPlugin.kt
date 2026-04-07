package com.example.appscrip_live_stream_component

import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AppscripLiveStreamComponentPlugin */
class AppscripLiveStreamComponentPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var appContext: Context

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
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
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
    } catch (_: Exception) {
    }

    try {
      val tone = ToneGenerator(AudioManager.STREAM_SYSTEM, 65)
      tone.startTone(ToneGenerator.TONE_PROP_ACK, 80)
      Handler(Looper.getMainLooper()).postDelayed(
        {
          try {
            tone.release()
          } catch (_: Exception) {
          }
        },
        120,
      )
    } catch (_: Exception) {
    }

    result.success(null)
  }

  /**
   * [VibrationEffect.EFFECT_CLICK] is very subtle; many users only notice sound. Prefer
   * [EFFECT_HEAVY_CLICK] on API 30+, strong one-shots below that, and [USAGE_TOUCH] on API 31+
   * so OEMs route this as UI feedback rather than dampening it.
   */
  private fun vibrateHeartTap(vibrator: Vibrator) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      @Suppress("DEPRECATION")
      vibrator.vibrate(65)
      return
    }

    val effect: VibrationEffect =
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK)
      } else {
        val amplitude =
          if (vibrator.hasAmplitudeControl()) {
            255
          } else {
            VibrationEffect.DEFAULT_AMPLITUDE
          }
        VibrationEffect.createOneShot(65, amplitude)
      }

    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val attrs =
          VibrationAttributes.Builder()
            .setUsage(VibrationAttributes.USAGE_TOUCH)
            .build()
        vibrator.vibrate(effect, attrs)
      } else {
        vibrator.vibrate(effect)
      }
    } catch (_: Exception) {
      try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          vibrator.vibrate(VibrationEffect.createOneShot(80, 255))
        } else {
          @Suppress("DEPRECATION")
          vibrator.vibrate(80)
        }
      } catch (_: Exception) {
      }
    }
  }
}
