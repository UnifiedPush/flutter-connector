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

var instance = "myInstance";

var endpoint = "";
var registered = false;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    UnifiedPush.initializeWithCallbackInstanciated(
        onNewEndpoint,
        onRegistrationFailed,
        onRegistrationRefused,
        onUnregistered,
        UPNotificationUtils.basicOnNotification,
        bgNewEndpoint, // called when new endpoint in background , need to be static
        bgUnregistered, // called when unregistered in background , need to be static
        bgOnMessage // called when receiving a message in background , need to be static
        );
    super.initState();
  }

  void onNewEndpoint(String _endpoint, String _instance) {
    if (_instance != instance) {
      return;
    }
    registered = true;
    endpoint = _endpoint;
    setState(() {
      print(endpoint);
    });
  }

  void onRegistrationRefused(String _instance) {
    //TODO
  }

  void onRegistrationFailed(String _instance) {
    //TODO
  }

  void onUnregistered(String _instance) {
    if (_instance != instance) {
      return;
    }
    registered = false;
    setState(() {
      print("unregistered");
    });
  }

  static bgOnMessage(dynamic args) {
    if (args["instance"] != instance) {
      return;
    }
    print(args["message"]);
    UPNotificationUtils.basicOnNotification(args["message"], args["instance"]);
  }

  static bgNewEndpoint(dynamic args) {
    if (args["instance"] != instance) {
      return;
    }
    print("BG: New endpoint: ${args["endpoint"]}");
    //TODO
  }

  static bgUnregistered(dynamic args) {
    if (args["instance"] != instance) {
      return;
    }
    print("BG: Unregistered");
    //TODO
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
            UnifiedPush.unregister(instance);
          } else {
            /**
             * Registration
             * Option 1:  Use the default distributor picker
             *            which uses a dialog
             */
            UnifiedPush.registerAppWithDialog(instance);
            /**
             * Registration
             * Option 2: Do your own function to pick the distrib
             */
            /*
            if (await UnifiedPush.getDistributor() != "") {
              UnifiedPush.registerApp(instance);
            } else {
              final distributors = await UnifiedPush.getDistributors();
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
          title: const Text('Multi Instances - Callback'),
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
