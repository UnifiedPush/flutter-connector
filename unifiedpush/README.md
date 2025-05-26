# UnifiedPush library

Library to subscribe and receive push notifications with UnifiedPush.

To receive notifications with UnifiedPush, users must have a dedicated application, a distributor, installed on their system.

## Initialize the receiver

When you initialize your application, register the different functions that will handle the incoming events with [UnifiedPush.initialize]:

```dart
UnifiedPush.initialize(
  onNewEndpoint: onNewEndpoint,
  onRegistrationFailed: onRegistrationFailed,
  onUnregistered: onUnregistered,
  onMessage: onMessage,
).then((registered) => { if (registered) UnifiedPush.register(instance) });

void onNewEndpoint(PushEndpoint endpoint, String instance) {
  // You should send the endpoint to your application server
  // and sync for missing notifications.
}

void onRegistrationFailed(FailedReason reason, String instance) {}

void onUnregistered(String instance) {}

void onMessage(PushMessage message, String instance) {}
```


## Register for push messages

When you try to register for the first time, you will probably want to use the user default distributor:

```dart
UnifiedPush.tryUseCurrentOrDefaultDistributor().then((success) {
  debugPrint("Current or Default found=$success");
  if (success) {
    UnifiedPush.registerApp(
        instance,                        // Optionnal String, to get multiple endpoints (one per instance)
        features = []                    // Optionnal String Array with required features, if a platform needs it
        vapid = vapid                    // Optionnal String with the server public VAPID key
    );
  } else {
    getUserChoice();                     // You UI function to has the distributor to use
  }
});
```

If using the current distrbutor doesn't succeed, or when you want to let the user chose a non-default distrbutor, you can implement your own logic:

```dart
void getUserChoice() {
  // Get a list of distributors that are available
  final distributors = await UnifiedPush.getDistributors(
      []                               // Optionnal String Array with required features
  );
  // select one or show a dialog or whatever
  final distributor = myPickerFunc(distributors);
  // save the distributor
  UnifiedPush.saveDistributor(distributor);
  // register your app to the distributor
  UnifiedPush.registerApp(
      instance,                        // Optionnal String, to get multiple endpoints (one per instance)
      features = []                    // Optionnal String Array with required features, if a platform needs it
      vapid = vapid                    // Optionnal String with the server public VAPID key
  );
}
```

If you want, [unifiedpush_ui](https://pub.dev/packages/unifiedpush_ui) provides a dialog to pick the user choice.

## Unregister

A registration can be canceled with `UnifiedPush.unregister`.

## Embed a distributor

On Android, this is possible to embed a distributor that will register to the Google play services directly. You will need to update the Android side of your flutter project. For more information refer to <https://unifiedpush.org/kdoc/embedded_fcm_distributor/>.

## Send push messages

You can then send web push messages to your applications. Web push is defined by 3 RFC: [RFC8030](https://www.rfc-editor.org/rfc/rfc8030) defines the content of the http request used to push a message, [RFC8291](https://www.rfc-editor.org/rfc/rfc8291) defines the (required) encryption of the push messages, and [RFC8292](https://www.rfc-editor.org/rfc/rfc8292) defines the authorization used to control the sender of push messages, this authoization is known as VAPID and is optional with most distributors, required by others.

When the application receives a new endpoint, it comes with information used by the server to encrypt notifications too: [PushEndpoint.pubKeySet].

The application automatically decrypt incoming notifications. When onNewMessage is called, [PushMessage.content] contains the decrypted content of the push notification. If it wasn't possible to correctly decrypt it, [PushMessage.decrypted] is false, and [PushMessage.content] contains the encrypted content of push notifications.

## Example

An example app can be found on the [repository](https://codeberg.org/UnifiedPush/flutter-connector/src/branch/main/example).
