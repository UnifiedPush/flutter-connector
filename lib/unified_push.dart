// import 'dart:async';

// import 'package:flutter/services.dart';

// class UnifiedPush {
//   static const MethodChannel _channel = const MethodChannel('unified_push');

//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }

//   static Future<List<String>> get distributors async {
//     List<String> ans;
//     try {
//       final List<String> result =
//           await _channel.invokeMethod('getDistributors');
//       ans = result;
//     } on PlatformException catch (e) {
//       //ans = "Failed to get dist: '${e.message}'.";
//       //throw e;
//       return null;
//     }

//     return ans;
//   }

//   static Future<String> register() async {
//     String a = "com.github.gotifyd";
//     String ans;
//     try {
//       ans = await _channel.invokeMethod('register', {"name": a});
//     } on PlatformException catch (e) {
//       //ans = "Failed to get token: '${e.message}'.";
//       return null;
//     }
//     return ans;
//   }
// }
