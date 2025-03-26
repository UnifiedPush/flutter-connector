import 'package:dbus/dbus.dart';

class OrgUnifiedpushDistributor2 extends DBusRemoteObject {
  OrgUnifiedpushDistributor2(
    super.client,
    String destination,
    DBusObjectPath path,
  ) : super(
          name: destination,
          path: path,
        );

  /// Invokes org.unifiedpush.Distributor2.Register()
  Future<Map<String, DBusValue>> callRegister(
    Map<String, DBusValue> args, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      'org.unifiedpush.Distributor2',
      'Register',
      [DBusDict.stringVariant(args)],
      replySignature: DBusSignature('a{sv}'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asStringVariantDict();
  }

  /// Invokes org.unifiedpush.Distributor2.Unregister()
  Future<Map<String, DBusValue>> callUnregister(
    Map<String, DBusValue> args, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      'org.unifiedpush.Distributor2',
      'Unregister',
      [DBusDict.stringVariant(args)],
      replySignature: DBusSignature('a{sv}'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asStringVariantDict();
  }
}
