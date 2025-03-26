import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:unifiedpush_platform_interface/data/failed_reason.dart';
import 'package:unifiedpush_platform_interface/data/push_endpoint.dart';
import 'package:unifiedpush_platform_interface/data/push_message.dart';

class OrgUnifiedpushConnector2 extends DBusObject {
  void Function(PushEndpoint endpoint)? _onNewEndpoint;
  // The DBus spec for UP doesn't actually seem to use this but our API is
  // providing the option for Android
  void Function(FailedReason reason)?
      _onRegistrationFailed; // ignore: unused_field
  void Function(String instance)? _onUnregistered;
  void Function(PushMessage message)? _onMessage;

  /// Creates a new object to expose on [path].
  OrgUnifiedpushConnector2({
    DBusObjectPath path = const DBusObjectPath.unchecked('/'),
  }) : super(path);

  Future<void> initializeCallback({
    void Function(PushEndpoint endpoint)? onNewEndpoint,
    void Function(FailedReason reason)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(PushMessage message)? onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;
  }

  /// Implementation of org.unifiedpush.Connector2.Message()
  Future<DBusMethodResponse> doMessage(Map<String, DBusValue> args) async {
    _onMessage?.call(
      PushMessage(
        Uint8List.fromList(args["message"]!.asByteArray().toList()),
        true,
      ),
    );

    return DBusMethodSuccessResponse();
  }

  /// Implementation of org.unifiedpush.Connector2.NewEndpoint()
  Future<DBusMethodResponse> doNewEndpoint(Map<String, DBusValue> args) async {
    _onNewEndpoint?.call(
      PushEndpoint(
        args["endpoint"]!.asString(),
        null,
      ),
    );

    return DBusMethodSuccessResponse();
  }

  /// Implementation of org.unifiedpush.Connector2.Unregistered()
  Future<DBusMethodResponse> doUnregistered(Map<String, DBusValue> args) async {
    _onUnregistered?.call(args["token"]!.asString());

    return DBusMethodSuccessResponse();
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.unifiedpush.Connector2', methods: [
        DBusIntrospectMethod(
          'Message',
          args: [
            DBusIntrospectArgument(
              DBusSignature('a{sv}'),
              DBusArgumentDirection.in_,
              name: 'args',
            ),
            DBusIntrospectArgument(
              DBusSignature('a{sv}'),
              DBusArgumentDirection.out,
              name: 'res',
            )
          ],
        ),
        DBusIntrospectMethod(
          'NewEndpoint',
          args: [
            DBusIntrospectArgument(
              DBusSignature('a{sv}'),
              DBusArgumentDirection.in_,
              name: 'args',
            ),
            DBusIntrospectArgument(
              DBusSignature('a{sv}'),
              DBusArgumentDirection.out,
              name: 'res',
            )
          ],
        ),
        DBusIntrospectMethod(
          'Unregistered',
          args: [
            DBusIntrospectArgument(
              DBusSignature('a{sv}'),
              DBusArgumentDirection.in_,
              name: 'args',
            ),
            DBusIntrospectArgument(
              DBusSignature('a{sv}'),
              DBusArgumentDirection.out,
              name: 'res',
            )
          ],
        )
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.unifiedpush.Connector2') {
      if (methodCall.name == 'Message') {
        if (methodCall.signature != DBusSignature('a{sv}')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doMessage(methodCall.values[0].asStringVariantDict());
      } else if (methodCall.name == 'NewEndpoint') {
        if (methodCall.signature != DBusSignature('a{sv}')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doNewEndpoint(methodCall.values[0].asStringVariantDict());
      } else if (methodCall.name == 'Unregistered') {
        if (methodCall.signature != DBusSignature('a{sv}')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doUnregistered(methodCall.values[0].asStringVariantDict());
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'org.unifiedpush.Connector2') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(
      String interface, String name, DBusValue value) async {
    if (interface == 'org.unifiedpush.Connector2') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }
}
