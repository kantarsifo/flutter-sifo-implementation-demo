import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kantar Sifo Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Kantar Sifo Flutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController cpidController =
      TextEditingController(text: "F53C7A3D013D4B89A1C1E697DC724467");
  final TextEditingController appNameController =
      TextEditingController(text: "App name");

  bool isPanelistOnly = false;
  bool isLogEnabled = false;
  bool isWebViewBased = false;
  bool frameworkInitialized = false;

  static const platform = MethodChannel('com.example.app/native');

  void _initializeFramework() async {
    try {
      final bool result = await platform.invokeMethod('initializeFramework', {
        'cpId': cpidController.text,
        'appName': appNameController.text,
        'isPanelistOnly': isPanelistOnly,
        'isLogEnabled': isLogEnabled,
        'isWebViewBased': isWebViewBased,
      });
      if (result) {
        setState(() {
          frameworkInitialized = result;
        });
      } else {
        print('Failed to initialize framework');
      }
    } on PlatformException catch (e) {
      print("Failed to initialize framework: '${e.message}'.");
    }
  }

  void _sendTag() async {
    try {
      await platform.invokeMethod('sendTag', {
        'category': "Some category",
        'contentID': "Some contentId",
      });
    } on PlatformException catch (e) {
      print("Failed to send tag: '${e.message}'.");
    }
  }

  void _destroyFramework() async {
    if (Platform.isAndroid) {
      try {
        final bool result = await platform.invokeMethod('destroyFramework');
        if (result) {
          setState(() {
            frameworkInitialized = false;
          });
        } else {
          print('Failed to destroy framework');
        }
      } on PlatformException catch (e) {
        print("Failed to destroy framework: '${e.message}'.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'CPID',
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                controller: cpidController,
                decoration: const InputDecoration(
                  hintText: 'Enter CPID',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'App Name',
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                controller: appNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter App Name',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Panelist Only'),
                  Checkbox(
                    value: isPanelistOnly,
                    onChanged: (val) {
                      setState(() {
                        isPanelistOnly = val!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Log'),
                  Checkbox(
                    value: isLogEnabled,
                    onChanged: (val) {
                      setState(() {
                        isLogEnabled = val!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Is WebView Based'),
                  Checkbox(
                    value: isWebViewBased,
                    onChanged: (val) {
                      setState(() {
                        isWebViewBased = val!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        frameworkInitialized
                            ? Colors.green.shade400
                            : Colors.grey.shade400,
                      ),
                    ),
                    onPressed: _initializeFramework,
                    child: Text(
                      frameworkInitialized
                          ? "Framework Initialized"
                          : 'Initialize framework',
                    ),
                  ),
                ],
              ),
              if (Platform.isAndroid)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _destroyFramework,
                      child: const Text('Destroy framework'),
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        frameworkInitialized ? null : Colors.grey.shade500,
                      ),
                    ),
                    onPressed: () {
                      if (frameworkInitialized) {
                        _sendTag();
                      }
                    },
                    child: const Text('Send Tag'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
