import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:device_apps/device_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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


void main() => runApp(const MyApp());

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
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'monitoring_channel_id',
      channelName: 'App Monitoring',
      channelDescription: 'Checks if a target app is running',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000, // this will actually be ignored in v5.2.1
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

  // Now safe to call
  await FlutterForegroundTask.saveData(key: 'callbackHandle', value: foregroundTaskCallback);
  await FlutterForegroundTask.startService(
    notificationTitle: 'Monitoring App',
    notificationText: 'Checking if target app is open...',
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
