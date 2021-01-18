import 'package:flutter/material.dart';
import 'dart:async';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'NotificationUtils.dart';

Future<void> main() async {
  runApp(MyApp());
  EasyLoading.instance.userInteractions = false;
}

UnifiedPush unifiedPush;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var endpoint = "";
  var registered = false;

  @override
  void initState() {
    UnifiedPush.initialize(
        onEndpointUpdate, UPNotificationUtils.basicOnNotification);
    super.initState();
  }

  void onEndpointUpdate() {
    setState(() {
      print(UnifiedPush.endpoint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomePage.routeName: (context) => HomePage()/*,
        ExtractArgumentsScreen.routeName: (context) => ExtractArgumentsScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),*/
      },
      builder: EasyLoading.init(),
    );
  }
}

class HomePage extends StatelessWidget {
  static const routeName = '/';

  final title = TextEditingController(text: "Notification Title");
  final message = TextEditingController(text: "Notification Body");

  void notify() async => await http.post(UnifiedPush.endpoint,
      body: "title=${title.text}&message=${message.text}&priority=6");

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [
      ElevatedButton(
        child: Text(UnifiedPush.registered ? 'Unregister' : "Register"),
        onPressed: () async {
          if (UnifiedPush.registered) {
            UnifiedPush.unRegister();
          } else {
            UnifiedPush.registerAppWithDialog();
          }
        },
      ),
    ];

    if (UnifiedPush.registered) {
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
                (UnifiedPush.registered ? UnifiedPush.endpoint : "empty")),
            Center(
              child: Column(
                children: row,
              ),
            ),
          ],
        ));
  }
}
