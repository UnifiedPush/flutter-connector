import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_unified_push/flutter_unified_push.dart';
import 'package:flutter_unified_push/Exceptions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

var uuid = Uuid();

Future<bool> onNotification(String title, String body, int priority) async {
  debugPrint("onNotification");
  print(title);
  if (!notificationInitialized) initNotifications();

  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      playSound: false, importance: Importance.max, priority: Priority.high);
  print(priority);
  var platformChannelSpecifics =
      new NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    uuid.v1().hashCode,
    title,
    body,
    platformChannelSpecifics,
    payload: 'No_Sound',
  );
  return true;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
var notificationInitialized = false;

void initNotifications() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final NotificationAppLaunchDetails notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  notificationInitialized = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings, onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    //selectNotificationSubject.add(payload);
  });
}

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

Future<void> main() async {
  runApp(MyApp());
}

FlutterUnifiedPush flutterUnifiedPush;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var endpoint = "";
  var registered = false;

  @override
  void initState() {
    flutterUnifiedPush = FlutterUnifiedPush();
    FlutterUnifiedPush.initialize(onEndpointUpdate, onNotification);
    super.initState();
  }

  void onEndpointUpdate() {
    setState(() {
      print(FlutterUnifiedPush.endpoint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomePage.routeName: (context) => HomePage(),
        ExtractArgumentsScreen.routeName: (context) => ExtractArgumentsScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
      },
      builder: EasyLoading.init(),
    );
  }
}

class HomePage extends StatelessWidget {
  static const routeName = '/';

  final title = TextEditingController(text: "Notification Title");
  final message = TextEditingController(text: "Noification Body");

  void notify() async => await http.post(FlutterUnifiedPush.endpoint,
      body: "title=${title.text}&message=${message.text}&priority=6");

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [
      ElevatedButton(
        child: Text(FlutterUnifiedPush.registered ? 'Unregister' : "Register"),
        onPressed: () async {
          if (FlutterUnifiedPush.registered) {
            FlutterUnifiedPush.unRegister();
          } else {
            Navigator.pushNamed(
              context,
              ExtractArgumentsScreen.routeName,
              arguments: await FlutterUnifiedPush.distributors,
            );
          }
        },
      ),
    ];

    if (FlutterUnifiedPush.registered) {
      row.add(ElevatedButton(child: Text("Notify"), onPressed: notify));
      row.add(
        TextField(
          controller: title,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Enter a search term'),
        ),
      );

      row.add(TextField(
        controller: message,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter a search term'),
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            SelectableText("Endpoint: " +
                (FlutterUnifiedPush.registered
                    ? FlutterUnifiedPush.endpoint
                    : "empty")),
            Center(
              child: Column(
                children: row,
              ),
            ),
          ],
        ));
  }
}

class ExtractArgumentsScreen extends StatelessWidget {
  static const routeName = '/extractArguments';

  @override
  Widget build(BuildContext context) {
    final List<String> dist = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pick provider"),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: dist.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dist[index]),
            onTap: () {
              Navigator.pushNamed(
                context,
                RegisterScreen.routeName,
                arguments: dist[index],
              );
            },
          );
        },
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  static const routeName = '/registerscreen';

  @override
  Widget build(BuildContext context) {
    final String dist = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: Column(children: [
          Text(dist),
          Center(
            child: RaisedButton(
              child: Text("Register with this provider"),
              onPressed: () async {
                EasyLoading.show(status: 'loading...');
                try {
                    await FlutterUnifiedPush.register(dist);
                    EasyLoading.showSuccess("Registered");
                } on RegistrationException catch (e) {
                    EasyLoading.showError(e.cause);
                  }
              
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(HomePage.routeName));
              },
            ),
          ),
        ]));
  }
}
