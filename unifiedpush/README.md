# UnifiedPush flutter-connector

UnifiedPush is specifications and tools that let the user choose how push notifications are delivered. All in a free and
open source way.

## Getting Started

Check out the documentation here:

1. <https://unifiedpush.org/developers/flutter/>
2. To have Firebase as a fallback, <https://unifiedpush.org/developers/embedded_fcm/>
3. An [example app](../example) can be found here.

## Migrating from UnifiedPush 5.x.x

With version 6.0.0, UnifiedPush removes

- `UnifiedPush.registerAppWithDialog`
- `UnifiedPush.removeNoDistributorDialogACK`

The reason is simple as:

The previous approach was using async gaps in the use of a `BuildContext`. With the new approach, we hand over the
possibility for devs to properly handle async gaps of the registration dialog on their own. Additionally, this enables a
custom registration dialog, localization and better integration into the embedding app. An additional advantage is a
more minimal dependency chain since storage of the UnifiedPush state is now the apps responsibility.

<details>

<summary> Implementation 5.x.x </summary>

```dart
Future<void> _myPushHandler() async {
  await UnifiedPush.registerAppWithDialog();
}

Future<void> _myPushRemoveNoHandler() async {
  await UnifiedPush.removeNoDistributorDialogACK();
}
```

</details>

<details>

<summary> Migrated to 6.0.0 </summary>

```dart

static const noDistribAck = "noDistributorAck";

Future<void> _myPushHandler() async {
  final distributor = await UnifiedPush.getDistributor();
  final prefs = await SharedPreferences.getInstance();
  String? picked;

  if (distributor == null) {
    final distributors = await getDistributors(features = features);
    if (distributors.isEmpty) {
      if (!(prefs.getBool(noDistribAck) ?? false)) {
        return showDialog(
            context: context,
            builder: noDistributorDialog(onDismissed: () {
              prefs.setBool(noDistribAck, true);
            }));
      }
    } else if (distributors.length == 1) {
      picked = distributors.single;
    } else {
      picked = await showDialog<String>(
        context: context,
        builder: pickDistributorDialog(distributors),
      );
    }

    if (picked != null) {
      await saveDistributor(picked);
    }
  }

  await registerApp(instance = instance, features = features);
}

Future<void> _myPushRemoveNoHandler() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(noDistribAck);
}


noDistributorDialog({required Null Function() onDismissed}) {
  return (BuildContext context) {
    return AlertDialog(
      title: const Text('Push Notifications'),
      content: const SingleChildScrollView(
          child: SelectableText(
              "You need to install a distributor for push notifications to work.\nYou can find more information at: https://unifiedpush.org/users/intro/")),
      actions: [
        TextButton(
          child: const Text('Dismiss'),
          onPressed: () {
            onDismissed();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  };
}

pickDistributorDialog(distributors) {
  return (BuildContext context) {
    return SimpleDialog(
        title: const Text('Select push distributor'),
        children: distributors
            .map<Widget>(
              (d) => SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, d);
            },
            child: Text(d),
          ),
        )
            .toList());
  };
}

```

</details>