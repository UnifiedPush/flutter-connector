import 'dart:math';

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
    UnifiedPush.initializeWithReceiver(
      onNewEndpoint: onNewEndpoint, // takes (String endpoint, String instance) in args
      onRegistrationFailed: onRegistrationFailed, // takes (String instance)
      onUnregistered: onUnregistered, // takes (String instance)
      onMessage: UPNotificationUtils.basicOnNotification, // takes (String message, String instance) in args
    );
    super.initState();
  }

  void onNewEndpoint(String _endpoint, String _instance) {
    registered = true;
    endpoint = _endpoint;
    setState(() {
      print(endpoint);
    });
  }

  void onRegistrationFailed(String _instance) {
    //TODO
  }

  void onUnregistered(String _instance) {
    registered = false;
    setState(() {
      print("unregistered");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {HomePage.routeName: (context) => HomePage()},
      builder: EasyLoading.init(),
    );
  }
}

class HomePage extends StatelessWidget {
  static const routeName = '/';

  final title = TextEditingController(text: "Notification Title");
  final message = TextEditingController(text: "Notification Body");

  void notify() async => await http.post(Uri.parse(endpoint),
      body: "title=${title.text}&message=${message.text}&priority=6");

  String myPickerFunc(List<String> distributors) {
    // Do not do a random func, this is an example.
    // You should do a context menu/dialog here
    Random rand = new Random();
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
            UnifiedPush.unregister();
          } else {
            /**
             * Registration
             * Option 1:  Use the default distributor picker
             *            which uses a dialog
             */
            UnifiedPush.registerAppWithDialog(context);
            /**
             * Registration
             * Option 2: Do your own function to pick the distrib
             */
            /*
            if (await UnifiedPush.getDistributor() != "") {
              UnifiedPush.registerApp();
            } else {
              final distributors = await UnifiedPush.getDistributors();
              if (distributors.length == 0) {
                return;
              }
              final distributor = myPickerFunc(distributors);
              UnifiedPush.saveDistributor(distributor);
              UnifiedPush.registerApp();
            }
            */
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
          title: const Text('Single Instance - Receiver'),
        ),
        body: Column(
          children: [
            SelectableText("Endpoint: " + (registered ? endpoint : "empty")),
            Center(
              child: Column(
                children: row,
              ),
            ),
          ],
        ));
  }
}
