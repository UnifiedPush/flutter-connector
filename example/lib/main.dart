import 'package:flutter/material.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'NotificationUtils.dart';

Future<void> main() async {
  runApp(MyApp());
  EasyLoading.instance.userInteractions = false;
}

UnifiedPush unifiedPush;

var endpoint = "";
var registered = false;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    UnifiedPush.initializeWithCallback(
        onNewEndpoint,
        onRegistrationFailed,
        onRegistrationRefused,
        onUnregistered,
        UPNotificationUtils.basicOnNotification,
        bgNewEndpoint, // called when new endpoint in background , need to be static
        bgUnregistered, // called when unregistered in background , need to be static
        UPNotificationUtils.basicOnNotification // called when receiving a message in background , need to be static
    );
    super.initState();
  }

  void onNewEndpoint(String _endpoint) {
    registered = true;
    endpoint = _endpoint;
    setState(() {
      print(endpoint);
    });
  }

  void onRegistrationRefused() {
    //TODO
  }

  void onRegistrationFailed() {
   //TODO
  }

  void onUnregistered() {
    registered = false;
    setState(() {
      print("unregistered");
    });
  }

  static bgNewEndpoint(String _endpoint) {
    print("BG: New endpoint: $_endpoint");
    //TODO
  }

  static bgUnregistered() {
    print("BG: Unregistered");
    //TODO
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomePage.routeName: (context) => HomePage()
      },
      builder: EasyLoading.init(),
    );
  }
}

class HomePage extends StatelessWidget {
  static const routeName = '/';

  final title = TextEditingController(text: "Notification Title");
  final message = TextEditingController(text: "Notification Body");

  void notify() async => await http.post(
      endpoint,
      body: "title=${title.text}&message=${message.text}&priority=6"
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [
      ElevatedButton(
        child: Text(registered ? 'Unregister' : "Register"),
        onPressed: () async {
          if (registered) {
            UnifiedPush.unregister();
          } else {
            UnifiedPush.registerAppWithDialog();
          }
        },
      ),
    ];

    if (registered) {
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
                (registered ? endpoint : "empty")),
            Center(
              child: Column(
                children: row,
              ),
            ),
          ],
        ));
  }
}
