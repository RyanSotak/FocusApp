import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
//import 'package:device_apps/device_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:isolate';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:permission_handler/permission_handler.dart';




void foregroundTaskCallback() async {
  const channel = MethodChannel('app_status');
  try {
    final isRunning = await channel.invokeMethod('isAppInForeground', {
      'packageName': 'com.whatsapp', // Replace with the package you want to check
    });
    print('App in foreground: $isRunning');
  } catch (e) {
    print('Error: $e');
  }
}

void openUsageAccessSettings() {
  const intent = AndroidIntent(
    action: 'android.settings.USAGE_ACCESS_SETTINGS',
  );
  intent.launch();
}

Future<void> checkIfAppInForeground(String packageName) async {
  const platform = MethodChannel('app_status');
  try {
    final bool isForeground = await platform.invokeMethod(
      'isAppInForeground',
      {'packageName': packageName},
    );
    debugPrint('$packageName is in foreground: $isForeground');
  } catch (e) {
    debugPrint('Error checking app status: $e');
  }
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //FlutterForegroundTask.setPluginRegistrant(registerPlugins);

  runApp(const MyApp());
}

// void registerPlugins() {
//   // Register your custom plugin.
//   AppStatusPlugin.registerWith();
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      home: const HomeScreen(),

    );
  }
}

Future<void> startForegroundService() async {
  if (Platform.isAndroid && await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'monitoring_channel_id',
      channelName: 'App Monitoring',
      channelDescription: 'Checks if a target app is running',
      playSound: true,
      enableVibration: true,
      showWhen: true,
      channelImportance: NotificationChannelImportance.HIGH, // NOTE: was channelImportance
      priority: NotificationPriority.HIGH,

    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(500),
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),


  );


  // Now safe to call
  await FlutterForegroundTask.startService(
    notificationTitle: 'Monitoring App',
    notificationText: 'Checking if target app is open...',
    callback: callbackDispatcher,
  );
}


Future<void> stopForegroundService() async {
  await FlutterForegroundTask.stopService();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          // onPressed: openUsageAccessSettings,
          // child: const Text('Grant Usage Access'),
          onPressed: startForegroundService,
          child: const Text('Start Background Monitor'),
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const SecondScreen()),
            // );


          //child: const Text('Go to Second Screen'),
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: const Center(
        child: Text(
          'Welcome to the second screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
@pragma('vm:entry-point')
void callbackDispatcher() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('[MyTaskHandler] Started at $timestamp');
    // Use starter.sendPort to communicate, if needed
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This now returns void and takes only DateTime
    const channel = MethodChannel('app_status');
    channel.invokeMethod('isAppInForeground', {
      'packageName': 'com.whatsapp',
    }).then((isRunning) {
      print('App in foreground: $isRunning');
    }).catchError((e) {
      print('Error: $e');
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('[MyTaskHandler] Destroyed at $timestamp, isTimeout: $isTimeout');
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('[MyTaskHandler] Button pressed: $id');
  }

  @override
  void onNotificationPressed() {
    print('[MyTaskHandler] Notification pressed');
  }
}
