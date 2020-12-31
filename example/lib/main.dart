import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_unified_push/flutter_unified_push.dart';

void main() {
  runApp(MyApp());
}

FlutterUnifiedPush flutterUnifiedPush;

class Preferences {
  static String endpoint = "";
  static bool registered = false;
  static String registrationToken = "";
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    if (Preferences.endpoint.isNotEmpty) {
      flutterUnifiedPush =
          FlutterUnifiedPush(Preferences.endpoint, onEndpointUpdate);
      Preferences.registered = true;
    } else {
      flutterUnifiedPush = FlutterUnifiedPush.first(onEndpointUpdate);
    }
  }

  void onEndpointUpdate() {
    setState(() {
      Preferences.endpoint = flutterUnifiedPush.endpoint;
      Preferences.registered = Preferences.endpoint.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(Preferences.endpoint);
    return MaterialApp(routes: {
      HomePage.routeName: (context) => HomePage(),
      ExtractArgumentsScreen.routeName: (context) => ExtractArgumentsScreen(),
      RegisterScreen.routeName: (context) => RegisterScreen(),
    });
  }
}

class HomePage extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    print(Preferences.registered);
    print(Preferences.endpoint);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            SelectableText("Endpoint: " +
                (Preferences.registered ? Preferences.endpoint : "empty")),
            Center(
              child: ElevatedButton(
                child: Text(Preferences.registered ? 'Unregister' : "Register"),
                onPressed: () async {
                  if (Preferences.registered) {
                    flutterUnifiedPush
                        .unRegister(Preferences.registrationToken);
                  } else {
                    Navigator.pushNamed(
                      context,
                      ExtractArgumentsScreen.routeName,
                      arguments: await flutterUnifiedPush.distributors,
                    );
                  }
                },
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
                Preferences.registrationToken =
                    await flutterUnifiedPush.register(dist);
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(HomePage.routeName));
              },
            ),
          ),
        ]));
  }
}
