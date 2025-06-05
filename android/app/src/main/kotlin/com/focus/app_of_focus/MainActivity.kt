package com.focus.app_of_focus

import io.flutter.embedding.android.FlutterActivity

import com.baseflow.permissionhandler.PermissionHandlerPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        FlutterForegroundTask.setPluginRegistrantCallback { registry ->
            PermissionHandlerPlugin.registerWith(registry.registrarFor("com.baseflow.permissionhandler.PermissionHandlerPlugin"))
            AppStatusPlugin.registerWith(registry.registrarFor("com.focus.app_of_focus.AppStatusPlugin"))
        }
    }
}
