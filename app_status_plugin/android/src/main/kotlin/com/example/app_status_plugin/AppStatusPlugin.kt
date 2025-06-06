package com.example.app_status_plugin

import android.app.ActivityManager
import android.app.usage.UsageStatsManager
import android.app.usage.UsageStats
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AppStatusPlugin */
val myList = mutableListOf("com.snapchat.android", "com.zhiliaoapp.musically", "com.google.android.youtube", "com.reddit.frontpage", "com.instagram.android", "com.discord")


class AppStatusPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app_status")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getForegroundApp" -> {
        result.success(getForegroundApp())
      }
      "getBatteryLevel" -> {
        result.success(getBatteryLevel())
      }
      else -> result.notImplemented()
    }
  }

  private fun getBatteryLevel(): Int {
    val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
  }

  private fun getForegroundApp(): String? {
    val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    val endTime = System.currentTimeMillis()
    val beginTime = endTime - 10000 // 10 seconds ago

    val usageStatsList: List<UsageStats> = usageStatsManager.queryUsageStats(
      UsageStatsManager.INTERVAL_DAILY, beginTime, endTime
    )
    if (usageStatsList.isNullOrEmpty()) {
      return null
    }
    val recentStat = usageStatsList.maxByOrNull { it.lastTimeUsed }
//    if (recentStat?.packageName in myList)
//    {
//      val intent = Intent()
//      intent.setClassName(context.packageName, "${context.packageName}.MainActivity")
//      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
//      context.startActivity(intent)
//    }
    return recentStat?.packageName
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
