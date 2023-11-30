@file:Suppress(
  "unused",
  "KDocUnresolvedReference",
  "MemberVisibilityCanBePrivate",
)

package com.nextstory.nextstory

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.util.ArrayMap
import java.lang.reflect.Field
import java.lang.reflect.Method

val currentApplication: Application
  get() {
    return ActivityThreads.currentApplicationMethod(null) as Application
  }

val foregroundActivity: Activity?
  get() {
    val activityThread = ActivityThreads.currentActivityThreadMethod(null)
    val activities = ActivityThreads.mActivitiesField.get(activityThread) as ArrayMap<*, *>
    for (e in activities.values) {
      if (!ActivityThreads.getPausedField(e).getBoolean(e)) {
        return ActivityThreads.getActivityField(e).get(e) as Activity?
      }
    }
    return null
  }

@SuppressLint("PrivateApi", "DiscouragedPrivateApi")
private object ActivityThreads {
  private var _activityThreadClass: Class<*>? = null
  val activityThreadClass: Class<*>
    get() = _activityThreadClass ?: Class.forName("android.app.ActivityThread")
      .also { _activityThreadClass = it }

  private var _currentApplicationMethod: Method? = null
  val currentApplicationMethod: Method
    get() = _currentApplicationMethod ?: activityThreadClass.getMethod("currentApplication")
      .also { _currentApplicationMethod = it }

  private var _currentActivityThreadMethod: Method? = null
  val currentActivityThreadMethod: Method
    get() = _currentActivityThreadMethod ?: activityThreadClass.getMethod("currentActivityThread")
      .also { _currentActivityThreadMethod = it }

  private var _mActivitiesField: Field? = null
  val mActivitiesField: Field
    get() = _mActivitiesField ?: activityThreadClass.getDeclaredField("mActivities")
      .also {
        _mActivitiesField = it
        _mActivitiesField!!.isAccessible = true
      }

  private var _pausedField: Field? = null
  fun getPausedField(obj: Any): Field {
    if (_pausedField == null) {
      _pausedField = obj.javaClass.getDeclaredField("paused")
      _pausedField!!.isAccessible = true
    }
    return _pausedField!!
  }

  private var _activityField: Field? = null
  fun getActivityField(obj: Any): Field {
    if (_activityField == null) {
      _activityField = obj.javaClass.getDeclaredField("activity")
      _activityField!!.isAccessible = true
    }
    return _activityField!!
  }
}
