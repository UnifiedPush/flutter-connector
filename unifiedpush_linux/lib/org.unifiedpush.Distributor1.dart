// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object unifiedpush_linux/lib/org.unifiedpush.Distributor1.xml

import 'package:dbus/dbus.dart';

class OrgUnifiedpushDistributor1 extends DBusRemoteObject {
  OrgUnifiedpushDistributor1(
    super.client,
    String destination,
    DBusObjectPath path,
  ) : super(
          name: destination,
          path: path,
        );

  /// Invokes org.unifiedpush.Distributor1.Register()
  Future<List<DBusValue>> callRegister(
    String serviceName,
    String token,
    String description, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      'org.unifiedpush.Distributor1',
      'Register',
      [
        DBusString(serviceName),
        DBusString(token),
        DBusString(description),
      ],
      replySignature: DBusSignature('ss'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }

  /// Invokes org.unifiedpush.Distributor1.Unregister()
  Future<void> callUnregister(
    String token, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      'org.unifiedpush.Distributor1',
      'Unregister',
      [
        DBusString(token),
      ],
      replySignature: DBusSignature(''),
      noReplyExpected: true,
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }
}
