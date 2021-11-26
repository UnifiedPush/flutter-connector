import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' show launch;

Widget noDistributorDialog(BuildContext context) => AlertDialog(
      title: Text('Push Notifications'),
      content: SingleChildScrollView(
          child: SelectableText(
              "You need to install a distributor for push notifications to work.\nYou can find more information at: https://unifiedpush.org/users/intro/")),
      actions: [
        TextButton(
          child: const Text('More Info'),
          onPressed: () => launch('https://unifiedpush.org/users/intro/'),
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );

pickDistributorDialog(dists) {
  return (BuildContext context) {
    return SimpleDialog(
        title: const Text('Select push distributor'),
        children: dists.entries
            .map<Widget>(
              (m) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, m.key);
                },
                child: Text(m.value),
              ),
            )
            .toList());
  };
}
