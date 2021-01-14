import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_unified_push/flutter_unified_push.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_easyloading/flutter_easyloading.dart';

Future<void> main() async {
  runApp(MyApp());
  EasyLoading.instance.userInteractions = false;
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
    FlutterUnifiedPush.initialize(
        onEndpointUpdate, UPNotificationUtils.basicOnNotification);
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
  final message = TextEditingController(text: "Notification Body");

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
