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

const localInstance = "myInstance";
// The Linux app name is used to register the application with DBus
// Because of this it needs to be a valid fully-qualified name
const linuxAppName = "org.unifiedpush.Example";

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
    debugPrint("Calling registerApp");
    await UnifiedPush.register(
      instance: instance,
      features: features,
    );
  }

  @override
  Future<void> saveDistributor(String distributor) async {
    await UnifiedPush.saveDistributor(distributor);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    UnifiedPush.initialize(
      onNewEndpoint:
          onNewEndpoint, // takes (String endpoint, String instance) in args
      onRegistrationFailed: onRegistrationFailed, // takes (String instance)
      onUnregistered: onUnregistered, // takes (String instance)
      onMessage: UPNotificationUtils
          .basicOnNotification, // takes (String message, String instance) in args
      linuxDBusName: linuxAppName,
    ).then((registered) {
      if (registered) {
        UnifiedPush.register(
          instance: localInstance,
        );
      }
    });
    _isAndroidPermissionGranted().catchError((err) {
      debugPrint("Exception while granting permissions");
    });
    super.initState();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  void onNewEndpoint(PushEndpoint nEndpoint, String instance) {
    if (instance != localInstance) {
      return;
    }
    registered = true;
    endpoint = nEndpoint;
    setState(() {
      debugPrint("Endpoint: ${endpoint.url}");
      debugPrint(
          "To test: https://unifiedpush.org/test_wp.html#endpoint=${endpoint.url}&p256dh=${endpoint.pubKeySet?.pubKey}&auth=${endpoint.pubKeySet?.auth}");
    });
  }

  void onRegistrationFailed(FailedReason reason, String instance) {
    onUnregistered(instance);
  }

  void onUnregistered(String instance) {
    if (instance != localInstance) {
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

class HomePage extends StatefulWidget {
  static const routeName = '/';
  final VoidCallback onPressed;

  const HomePage({
    required this.onPressed,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController title =
      TextEditingController(text: "Notification Title");
  TextEditingController message =
      TextEditingController(text: "Notification Body");

  @override
  void dispose() {
    title.dispose();
    message.dispose();

    super.dispose();
  }

  Future<void> notify() async {
    final resp = await http.post(Uri.parse(endpoint.url),
        headers: {"content-encoding": "aes128gcm", "ttl": "5"},
        body: "title=${title.text}&message=${message.text}&priority=6");
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

  void registerWithDefault(UnifiedPushUi upDialogs) {
    UnifiedPush.tryUseCurrentOrDefaultDistributor().then((success) {
      debugPrint("Current or Default found=$success");
      if (success) {
        UnifiedPush.register(instance: localInstance);
      } else {
        upDialogs.registerAppWithDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = endpoint.pubKeySet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unifiedpush Example'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: Text(registered ? 'Re-register' : "Register"),
              onPressed: () async {
                if (registered) {
                  UPFunctions().registerApp(localInstance);
                } else {
                  /**
                   * Registration
                   * Option 1:  Use the default distributor picker
                   *            which uses a dialog
                   */
                  registerWithDefault(
                    UnifiedPushUi(
                      context,
                      [localInstance],
                      UPFunctions(),
                    ),
                  );

                  /**
                   * Registration
                   * Option 2: Do your own function to pick the distrib
                   */
                  /*
                    if (await UnifiedPush.tryUseCurrentOrDefaultDistributor()) {
                      UnifiedPush.registerApp(instance);
                    } else {
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
            if (registered) ...[
              ElevatedButton(
                  child: Text("Unregister"),
                  onPressed: () async {
                    UnifiedPush.unregister(localInstance);
                    registered = false;
                    widget.onPressed();
                  }),
              SelectableText("Endpoint: ${endpoint.url}"),
              if (key != null) ...[
                SelectableText("P256dh: ${key.pubKey}"),
                SelectableText("Auth: ${key.auth}"),
              ],
              ElevatedButton(
                onPressed: notify,
                child: const Text("Notify"),
              ),
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a title',
                ),
              ),
              TextField(
                controller: message,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a body',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
