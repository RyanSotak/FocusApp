package com.focus.app_of_focus

//import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import android.app.usage.UsageEvents
//import android.app.usage.UsageStatsManager
//import android.content.Context
//import com.pravera.flutter_foreground_task.FlutterForegroundTaskPlugin

import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry
import com.focus.app_of_focus.AppStatusPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterForegroundTask.setPluginRegistrant { flutterEngine ->
            // Register your plugin for background isolates
            val shimRegistry = ShimPluginRegistry(flutterEngine)
            AppStatusPlugin.registerWith(shimRegistry.registrarFor("com.focus.app_of_focus.AppStatusPlugin"))
        }
    }
}

//class MainActivity : FlutterActivity() {
//    private val CHANNEL = "app_status"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "isAppInForeground") {
//                val packageName = call.argument<String>("packageName")
//                if (packageName != null) {
//                    val isForeground = isAppCurrentlyForeground(packageName)
//                    result.success(isForeground)
//                } else {
//                    result.error("NO_PACKAGE", "No package name provided", null)
//                }
//            } else {
//                result.notImplemented()
//            }
//        }
//    }
//
//    private fun isAppCurrentlyForeground(targetPackage: String): Boolean {
//        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
//        val time = System.currentTimeMillis()
//        val usageEvents = usm.queryEvents(time - 10_000, time)
//        val event = UsageEvents.Event()
//
//        var lastForeground = false
//        while (usageEvents.hasNextEvent()) {
//            usageEvents.getNextEvent(event)
//            if (event.packageName == targetPackage &&
//                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
//                lastForeground = true
//            }
//            if (event.packageName == targetPackage &&
//                event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND) {
//                lastForeground = false
//            }
//        }
//
//        return lastForeground
//    }
//}
