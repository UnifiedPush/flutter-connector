import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:unifiedpush_ui/unifiedpush_ui.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'notification_utils.dart';

Future<void> main() async {
  runApp(const MyApp());
  EasyLoading.instance.userInteractions = false;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

var instance = "myInstance";

var endpoint = PushEndpoint("undefined", null);
var registered = false;

class UPFunctions extends UnifiedPushFunctions {
  final List<String> features = [/*list of features*/];
  @override
  Future<String?> getDistributor() async {
    return await UnifiedPush.getDistributor();
  }

  @override
  Future<List<String>> getDistributors() async {
    return await UnifiedPush.getDistributors(features);
  }

  @override
  Future<void> registerApp(String instance) async {
    await UnifiedPush.registerApp(instance, features);
  }

  @override
  Future<void> saveDistributor(String distributor) async {
    await UnifiedPush.saveDistributor(distributor);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    UnifiedPush.initialize(
      onNewEndpoint:
          onNewEndpoint, // takes (String endpoint, String instance) in args
      onRegistrationFailed: onRegistrationFailed, // takes (String instance)
      onUnregistered: onUnregistered, // takes (String instance)
      onMessage: UPNotificationUtils
          .basicOnNotification, // takes (String message, String instance) in args
    );
    try {
      _isAndroidPermissionGranted();
    } on Exception catch(_) {
      debugPrint("Exception while granting permissions");
    }
      super.initState();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation
          ?.requestNotificationsPermission()
          .catchError(print);
    }
  }

  void onNewEndpoint(PushEndpoint _endpoint, String _instance) {
    if (_instance != instance) {
      return;
    }
    registered = true;
    endpoint = _endpoint;
    setState(() {
      debugPrint("Endpoint: ${_endpoint.url}");
      debugPrint("To test: https://unifiedpush.org/test_wp.html#endpoint=${_endpoint.url}&p256dh=${_endpoint.pubKeySet?.pubKey}&auth=${_endpoint.pubKeySet?.auth}");
    });
  }

  void onRegistrationFailed(FailedReason reason, String _instance) {
    onUnregistered(_instance);
  }

  void onUnregistered(String _instance) {
    if (_instance != instance) {
      return;
    }
    registered = false;
    setState(() {
      debugPrint("unregistered");
    });
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {HomePage.routeName: (context) => HomePage(onPressed: refresh)},
      builder: EasyLoading.init(),
    );
  }
}

class HomePage extends StatelessWidget {
  static const routeName = '/';
  final VoidCallback onPressed;

  final title = TextEditingController(text: "Notification Title");
  final message = TextEditingController(text: "Notification Body");

  HomePage({Key? key, required this.onPressed}) : super(key: key);

  Future<void> notify() async {
    final resp = await http.post(
        Uri.parse(endpoint.url),
        headers: {
          "content-encoding": "aes128gcm",
          "ttl": "5"
        },
        body: "title=${title.text}&message=${message.text}&priority=6"
    );
    debugPrint("resp: ${resp.statusCode}");
  }

  String myPickerFunc(List<String> distributors) {
    // Do not do a random func, this is an example.
    // You should do a context menu/dialog here
    Random rand = Random();
    final max = distributors.length;
    final index = rand.nextInt(max);
    return distributors[index];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [
      ElevatedButton(
        child: Text(registered ? 'Unregister' : "Register"),
        onPressed: () async {
          if (registered) {
            UnifiedPush.unregister(instance);
            registered = false;
            onPressed();
          } else {
            /**
             * Registration
             * Option 1:  Use the default distributor picker
             *            which uses a dialog
             */
            UnifiedPushUi(context, [instance], UPFunctions())
                .registerAppWithDialog();
            /**
             * Registration
             * Option 2: Do your own function to pick the distrib
             */
            /*
            if (await UnifiedPush.getDistributor() != "") {
              UnifiedPush.registerApp(instance);
            } else {
              UnifiedPush.removeNoDistributorDialogACK();
              final distributors = await UnifiedPush.getDistributors();
              if (distributors.length == 0) {
                return;
              }
              final distributor = myPickerFunc(distributors);
              UnifiedPush.saveDistributor(distributor);
              UnifiedPush.registerApp(instance);
            }
            */
          }
        },
      ),
    ];

    if (registered) {
      row.add(SelectableText("Endpoint: ${endpoint.url}"));
      final key = endpoint.pubKeySet;
      if (key != null) {
        row.add(SelectableText("P256dh: ${key.pubKey}"));
        row.add(SelectableText("Auth: ${key.auth}"));
      }
      row.add(ElevatedButton(onPressed: notify, child: const Text("Notify")));
      row.add(
        TextField(
          controller: title,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter a title'),
        ),
      );
      row.add(TextField(
        controller: message,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), hintText: 'Enter a body'),
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Unifiedpush Example'),
        ),
        body: Center(
          child: Column(
            children: row,
          ),
        ));
  }
}
