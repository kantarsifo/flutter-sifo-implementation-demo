# Kantar Sifo Flutter Demo
This demo is to show how to integrate platform specific libraries of kantar sifo in flutter

# SETUP

# Android

## Step 1:
In android/build.gradle add:
```
allprojects {
    repositories {
        maven { url 'https://jitpack.io' }
    }
}
```

## Step 2:
In android/app/build.gradle add:
```
dependencies {
    implementation 'com.github.kantarsifo:SifoInternetAndroidSDK:4.x.x’
}
```

## Step 3:
In MainActivity change from:
```java
    class MainActivity: FlutterActivity()
```
to:
```java
class MainActivity: FlutterFragmentActivity()
```
this is so that createInstance accepts the activity as a parameter

### For more details: https://github.com/kantarsifo/SifoInternetAndroidSDK

# IOS

## Step 1:

Add library to project

Swift Package Manager:
```shell
source 'https://github.com/kantarsifo/SifoInternet_IOS_SDK.git'
```

## Step 2:

Add url scheme, query scheme and user tracking usage

Update your info.plist to include. Add query scheme:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>se.tns-sifo.internetpanelen</string>
</array>
```
Add url scheme with <your_bundle_id>.tsmobileanalytics:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>None</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>my.example.id.tsmobileanalytics</string>
    </array>
  </dict>
</array>
```

### For more details: https://github.com/kantarsifo/SifoInternet_IOS_SDK

# Connecting Everything

## Android

## Step 1:
Override this function:
```kotlin
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
}
```
## Step 2:
Add needed method channels: ["initializeFramework", "sendTag", "destroyFramework"]

Method channel example:
```kotlin
MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "initializeFramework") {}
        }
```
When "initializeFramework" will be called it will invoke whatever 
is inside the function of that method call

Everything from here is calling the functions just like in native android

## IOS

## Step 1:
add channel:
```objectivec
let channel = FlutterMethodChannel(name: "com.example.app/native", binaryMessenger: controller.binaryMessenger)
```
## Step 2:
Add needed method channels: ["initializeFramework", "sendTag"] (ios package of kantar sifo does not have destroy framework)

Method channel example:
```objectivec
channel.setMethodCallHandler { [self] (call, result) in
        if call.method == "initializeFramework" {}
}
```

When "initializeFramework" will be called it will invoke whatever
is inside the function of that method call

Everything from here is calling the functions just like in native ios

# Flutter

## Step 1
Create a channel:
```dart
  static const platform = MethodChannel('com.example.app/native');
```

## Step 2
Call methods and send data

### initializeFramework:

```dart
void _initializeFramework() async {
    try {
      final bool result = await platform.invokeMethod('initializeFramework', {
        'cpId': string,
        'appName': string,
        'isPanelistOnly': bool,
        'isLogEnabled': bool,
        'isWebViewBased': bool,
      });
    } on PlatformException catch (e) {
      print("Failed to initialize framework: '${e.message}'.");
    }
  }
```

### sendTag:

```dart
void _sendTag() async {
  try {
    await platform.invokeMethod('sendTag', {
      'category': string,
      'contentID': string,
    });
  } on PlatformException catch (e) {
    print("Failed to send tag: '${e.message}'.");
  }
}
```

### destroyFramework (Android only)
```dart
void _destroyFramework() async {
  if (Platform.isAndroid) {
    try {
      final bool result = await platform.invokeMethod('destroyFramework');
    } on PlatformException catch (e) {
      print("Failed to destroy framework: '${e.message}'.");
    }
  }
}
```
