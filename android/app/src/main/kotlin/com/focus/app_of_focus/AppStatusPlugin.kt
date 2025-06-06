package com.focus.app_of_focus

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AppStatusPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app_status")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (call.method == "isAppInForeground") {
            val packageName = call.argument<String>("packageName")
            if (packageName != null) {
                result.success(isAppCurrentlyForeground(packageName))
            } else {
                result.error("NO_PACKAGE", "No package name provided", null)
            }
        } else {
            result.notImplemented()
        }
    }

    private fun isAppCurrentlyForeground(targetPackage: String): Boolean {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val usageEvents = usm.queryEvents(time - 10_000, time)
        val event = UsageEvents.Event()

        var lastForeground = false
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.packageName == targetPackage &&
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                lastForeground = true
            }
            if (event.packageName == targetPackage &&
                event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND) {
                lastForeground = false
            }
        }
        return lastForeground
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
