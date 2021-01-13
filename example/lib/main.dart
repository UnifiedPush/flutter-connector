import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_unified_push/flutter_unified_push.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
  WidgetsFlutterBinding.ensureInitialized();

  // final NotificationAppLaunchDetails notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    //selectNotificationSubject.add(payload);
  });

  runApp(MyApp());
}

FlutterUnifiedPush flutterUnifiedPush;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    flutterUnifiedPush = FlutterUnifiedPush();
FlutterUnifiedPush.onNotificationMethod = onNotification;
  }

  Future<void> onNotification(String title, String body, int priority) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        playSound: false, importance: Importance.max, priority: Priority.high);
    print(priority);
    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'No_Sound',
    );
  }

  void onEndpointUpdate() {
    setState(() {
      debugPrint(FlutterUnifiedPush.endpoint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      HomePage.routeName: (context) => HomePage(),
      ExtractArgumentsScreen.routeName: (context) => ExtractArgumentsScreen(),
      RegisterScreen.routeName: (context) => RegisterScreen(),
    });
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
                await FlutterUnifiedPush.register(dist);
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(HomePage.routeName));
              },
            ),
          ),
        ]));
  }
}
