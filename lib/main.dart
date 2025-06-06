import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
//import 'package:device_apps/device_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:isolate';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

const MethodChannel channel = MethodChannel('Battery');



class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Optional: Initialization logic
  }

  Future<void> _getBatteryLevel() async {
    String processList;
    try {
      final processes = await channel.invokeMethod<String>('getRunningApps');
      //processList = 'Processes: ${processes?.join(', ') ?? "None"}';
      processList = processes.toString();
      if (kDebugMode) {
        debugPrint(processList);
      }
    } on PlatformException catch (e) {
      processList = "Failed to get processes: '${e.message}'.";
    }
    // setState(() {
    //   _batteryLevel = processList;
    // });
    // setState(() {
    //   _batteryLevel = batteryLevel;
    // });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _getBatteryLevel();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
  @override
  void onNotificationButtonPressed(String id) {}
  @override
  void onNotificationPressed() {}
}

void foregroundTaskCallback() async {
  const channel = MethodChannel('Battery');
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  //static const platform = MethodChannel('Battery');
  // String _batteryLevel = 'Unknown battery level.';


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Home')),

        body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: openUsageAccessSettings,
                  child: const Text('Grant Usage Access'),
                ),
                const SizedBox(height: 16), // spacing between buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SecondScreen()),
                    );
                  },
                  child: const Text('Go to App selection menu!'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: startForegroundService,
                  child: const Text('Start Monitoring'),
                ),
              ],
            )
        )
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Material(
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           ElevatedButton(
  //             onPressed: _getBatteryLevel,
  //             child: const Text('Get Battery Level'),
  //           ),
  //           Text(_batteryLevel),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Navigation Demo',
//       home: const HomeScreen(),
//
//     );
//   }
// }

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

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//
//         body: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton(
//                 onPressed: openUsageAccessSettings,
//                 child: const Text('Grant Usage Access'),
//               ),
//               const SizedBox(height: 16), // spacing between buttons
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const SecondScreen()),
//                   );
//                 },
//                 child: const Text('Go to App selection menu!'),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: startForegroundService,
//                 child: const Text('Start Monitoring'),
//               ),
//             ],
//           )
//         )
//       );
//     }
//   }




class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  // Simulated list of apps
  final List<String> apps = ['Instagram', 'YouTube', 'TikTok', 'Snapchat', 'Reddit', 'Discord'];

  // Track which apps are selected
  final Set<String> selectedApps = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps to Block'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: apps.map((app) {
            final isSelected = selectedApps.contains(app);
            return FilterChip(
              label: Text(app),
              selected: isSelected,
              selectedColor: Colors.red.shade200,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedApps.add(app);
                  } else {
                    selectedApps.remove(app);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

}


@pragma('vm:entry-point')
void callbackDispatcher() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

// class MyTaskHandler extends TaskHandler {
//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//     if (kDebugMode) {
//       debugPrint('[MyTaskHandler] Started at $timestamp');
//     }
//     // Use starter.sendPort to communicate, if needed
//   }
//
//   Future<void> _getBatteryLevel() async {
//     String processList;
//     try {
//       final processes = await platform.invokeMethod<String>('getRunningApps');
//       //processList = 'Processes: ${processes?.join(', ') ?? "None"}';
//       processList = processes.toString();
//       if (kDebugMode) {
//         debugPrint(processList);
//       }
//     } on PlatformException catch (e) {
//       processList = "Failed to get processes: '${e.message}'.";
//     }
//     // setState(() {
//     //   _batteryLevel = processList;
//     // });
//     // setState(() {
//     //   _batteryLevel = batteryLevel;
//     // });
//   }
//
//   @override
//   void onRepeatEvent(DateTime timestamp) {
//     _getBatteryLevel();
//   }
//
//   @override
//   Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
//     print('[MyTaskHandler] Destroyed at $timestamp, isTimeout: $isTimeout');
//   }
//
//   @override
//   void onNotificationButtonPressed(String id) {
//     print('[MyTaskHandler] Button pressed: $id');
//   }
//
//   @override
//   void onNotificationPressed() {
//     print('[MyTaskHandler] Notification pressed');
//   }
// }

