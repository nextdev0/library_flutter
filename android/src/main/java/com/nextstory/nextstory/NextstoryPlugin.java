package com.nextstory.nextstory;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.NonNull;

import java.lang.reflect.Field;
import java.io.File;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * NextstoryPlugin
 */
public class NextstoryPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "nextstory");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Activity activity = Utils.getActivity();

    switch (call.method) {
      case "enableAndroidTransparentNavigationBar":
        if (activity != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          activity.getWindow().setNavigationBarColor(Color.TRANSPARENT);
        }
        result.success(null);
        break;

      case "mediaScan":
        if (activity != null) {
          try {
            String path = call.argument("path");
            File file = new File(path);
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
              activity.sendBroadcast(
                  new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file)));
            } else {
              new MediaScanner(activity, file.getAbsolutePath()).connect();
            }
          } catch (Exception ignored) {
          }
        }
        result.success(null);
        break;

      default:
      case "disableDelayTouchesBeganIOS":
        result.success(null);
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}

class MediaScanner implements MediaScannerConnection.MediaScannerConnectionClient {
  final MediaScannerConnection mediaScannerConnection;
  final String path;

  public MediaScanner(Context context, String path) {
    this.mediaScannerConnection = new MediaScannerConnection(context, this);
    this.path = path;
  }

  @Override
  public void onMediaScannerConnected() {
    mediaScannerConnection.scanFile(path, null);
  }

  @Override
  public void onScanCompleted(String path, Uri uri) {
    mediaScannerConnection.disconnect();
  }

  public void connect() {
    mediaScannerConnection.connect();
  }
}

class Utils {
  private Utils() {
    // no-op
  }

  @SuppressLint("PrivateApi")
  @SuppressWarnings("unchecked")
  public static Activity getActivity() {
    try {
      Class<?> activityThreadClass = Class.forName("android.app.ActivityThread");
      Object activityThread = activityThreadClass.getMethod("currentActivityThread")
          .invoke(null);
      Field activitiesField = activityThreadClass.getDeclaredField("mActivities");
      activitiesField.setAccessible(true);

      Map<Object, Object> activities =
          (Map<Object, Object>) activitiesField.get(activityThread);
      if (activities == null) {
        return null;
      }

      for (Object activityRecord : activities.values()) {
        Class<?> activityRecordClass = activityRecord.getClass();
        Field pausedField = activityRecordClass.getDeclaredField("paused");
        pausedField.setAccessible(true);
        if (!pausedField.getBoolean(activityRecord)) {
          Field activityField = activityRecordClass.getDeclaredField("activity");
          activityField.setAccessible(true);
          return (Activity) activityField.get(activityRecord);
        }
      }
    } catch (Exception ignored) {
    }
    return null;
  }
}
