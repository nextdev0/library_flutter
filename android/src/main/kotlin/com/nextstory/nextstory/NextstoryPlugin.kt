@file:Suppress("SpellCheckingInspection")

package com.nextstory.nextstory

import android.content.pm.ActivityInfo
import android.graphics.Color
import android.media.MediaScannerConnection
import android.os.Build
import android.view.View
import android.view.WindowManager
import androidx.core.view.WindowCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONException

class NextstoryPlugin : FlutterPlugin, MethodCallHandler {
  private var channel: MethodChannel? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "nextstory")
    channel?.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }

  @Suppress("DEPRECATION")
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val activity = foregroundActivity
    if (activity == null) {
      result.success(null)
      return
    }

    when (call.method) {
      "mediaScan" -> {
        MediaScannerConnection.scanFile(
          activity,
          arrayOf(call.argument("path")),
          null,
        ) { _, _ ->
          result.success(null)
        }
      }

      "getAndroidSdkVersion" -> {
        result.success(Build.VERSION.SDK_INT)
      }

      "applySystemTheme" -> {
        val window = activity.window

        // 전체화면 / 기본 적용
        if (call.argument<Boolean>("fullscreen") == true) {
          window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_FULLSCREEN)
        } else {
          window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
        }

        // 구버전 지원
        if (Build.VERSION.SDK_INT < 30) {
          window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
          window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
          window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
        }

        // 아이콘 색상
        val insetsController = WindowCompat.getInsetsController(window, window.decorView)!!
        insetsController.isAppearanceLightStatusBars =
          call.argument<Boolean>("statusDarkIcon") == true
        insetsController.isAppearanceLightNavigationBars =
          call.argument<Boolean>("navigationDarkIcon") == true

        // 기본 색상 제거
        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.TRANSPARENT
        if (Build.VERSION.SDK_INT >= 28) {
          window.navigationBarDividerColor = Color.TRANSPARENT
        }

        // 아이콘 자동 색상 비활성화
        if (Build.VERSION.SDK_INT >= 29) {
          window.isStatusBarContrastEnforced = false
          window.isNavigationBarContrastEnforced = false
        }

        // 컷아웃 지원
        if (Build.VERSION.SDK_INT >= 28) {
          window.attributes.layoutInDisplayCutoutMode =
            WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }

        result.success(null)
      }

      "applyScreenOrientation" -> {
        activity.requestedOrientation = DeviceOrientation.decodeOrientations(
          call.argument<List<String>>("orientations")!!,
        )
        result.success(null)
      }

      else -> {
        result.success(null)
      }
    }
  }

  internal enum class DeviceOrientation(private val encodedName: String) {
    PORTRAIT_UP("DeviceOrientation.portraitUp"),
    PORTRAIT_DOWN("DeviceOrientation.portraitDown"),
    LANDSCAPE_LEFT("DeviceOrientation.landscapeLeft"),
    LANDSCAPE_RIGHT("DeviceOrientation.landscapeRight");

    companion object {
      @Throws(NoSuchFieldException::class)
      fun fromValue(encodedName: String): DeviceOrientation {
        for (orientation in DeviceOrientation.values()) {
          if (orientation.encodedName == encodedName) {
            return orientation
          }
        }
        throw NoSuchFieldException("No such DeviceOrientation: $encodedName")
      }


      @Throws(JSONException::class, NoSuchFieldException::class)
      fun decodeOrientations(encodedOrientations: List<String>): Int {
        var requestedOrientation = 0x00
        var firstRequestedOrientation = 0x00
        var index = 0
        while (index < encodedOrientations.count()) {
          val encodedOrientation = encodedOrientations[index]
          val orientation = DeviceOrientation.fromValue(encodedOrientation)
          requestedOrientation = when (orientation) {
            PORTRAIT_UP -> requestedOrientation or 0x01
            PORTRAIT_DOWN -> requestedOrientation or 0x04
            LANDSCAPE_LEFT -> requestedOrientation or 0x02
            LANDSCAPE_RIGHT -> requestedOrientation or 0x08
          }
          if (firstRequestedOrientation == 0x00) {
            firstRequestedOrientation = requestedOrientation
          }
          index += 1
        }

        when (requestedOrientation) {
          0x00 -> return ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
          0x01 -> return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
          0x02 -> return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
          0x04 -> return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT
          0x05 -> return ActivityInfo.SCREEN_ORIENTATION_USER_PORTRAIT
          0x08 -> return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE
          0x0a -> return ActivityInfo.SCREEN_ORIENTATION_USER_LANDSCAPE
          0x0b -> return ActivityInfo.SCREEN_ORIENTATION_USER
          0x0f -> return ActivityInfo.SCREEN_ORIENTATION_FULL_USER
          0x03, 0x06, 0x07, 0x09, 0x0c, 0x0d, 0x0e -> when (firstRequestedOrientation) {
            0x01 -> return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            0x02 -> return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            0x04 -> return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT
            0x08 -> return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE
          }
        }

        return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
      }
    }
  }
}
