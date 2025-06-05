import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:device_apps/device_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';
import 'package:flutter/services.dart';


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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecondScreen()),
                  );
                },
                child: const Text('Start Monitoring'),
              ),
            ],
          ),
        ),
    );
  }
}




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