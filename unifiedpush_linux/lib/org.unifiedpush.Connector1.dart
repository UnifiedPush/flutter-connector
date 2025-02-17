import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:unifiedpush_platform_interface/data/failed_reason.dart';
import 'package:unifiedpush_platform_interface/data/push_endpoint.dart';
import 'package:unifiedpush_platform_interface/data/push_message.dart';

class OrgUnifiedpushConnector1 extends DBusObject {
  void Function(PushEndpoint endpoint)? _onNewEndpoint;
  // The DBus spec for UP doesn't actually seem to use this but our API is
  // providing the option for Android
  void Function(FailedReason reason)?
      _onRegistrationFailed; // ignore: unused_field
  void Function(String instance)? _onUnregistered;
  void Function(PushMessage message)? _onMessage;

  /// Creates a new object to expose on [path].
  OrgUnifiedpushConnector1()
      : super(const DBusObjectPath.unchecked('/org/unifiedpush/Connector'));

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

  /// Implementation of org.unifiedpush.Connector1.Message()
  Future<void> doMessage(
    String token,
    List<int> message,
    String messageIdentifier,
  ) async =>
      _onMessage?.call(PushMessage(Uint8List.fromList(message), true));

  /// Implementation of org.unifiedpush.Connector1.NewEndpoint()
  Future<void> doNewEndpoint(String token, String endpoint) async =>
      _onNewEndpoint?.call(PushEndpoint(endpoint, null));

  /// Implementation of org.unifiedpush.Connector1.Unregistered()
  Future<void> doUnregistered(String token) async =>
      _onUnregistered?.call(token);

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.unifiedpush.Connector1', methods: [
        DBusIntrospectMethod('Message', args: [
          DBusIntrospectArgument(
            DBusSignature('s'),
            DBusArgumentDirection.in_,
            name: 'token',
          ),
          DBusIntrospectArgument(
            DBusSignature('ay'),
            DBusArgumentDirection.in_,
            name: 'message',
          ),
          DBusIntrospectArgument(
            DBusSignature('s'),
            DBusArgumentDirection.in_,
            name: 'messageIdentifier',
          )
        ]),
        DBusIntrospectMethod('NewEndpoint', args: [
          DBusIntrospectArgument(
            DBusSignature('s'),
            DBusArgumentDirection.in_,
            name: 'token',
          ),
          DBusIntrospectArgument(
            DBusSignature('s'),
            DBusArgumentDirection.in_,
            name: 'endpoint',
          )
        ]),
        DBusIntrospectMethod('Unregistered', args: [
          DBusIntrospectArgument(
            DBusSignature('s'),
            DBusArgumentDirection.in_,
            name: 'token',
          )
        ])
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.unifiedpush.Connector1') {
      if (methodCall.name == 'Message') {
        if (methodCall.signature != DBusSignature('says')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        await doMessage(
          methodCall.values[0].asString(),
          methodCall.values[1].asByteArray().toList(),
          methodCall.values[2].asString(),
        );
        return DBusMethodSuccessResponse();
      } else if (methodCall.name == 'NewEndpoint') {
        if (methodCall.signature != DBusSignature('ss')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        await doNewEndpoint(
          methodCall.values[0].asString(),
          methodCall.values[1].asString(),
        );
        return DBusMethodSuccessResponse();
      } else if (methodCall.name == 'Unregistered') {
        if (methodCall.signature != DBusSignature('s')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        await doUnregistered(methodCall.values[0].asString());
        return DBusMethodSuccessResponse();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'org.unifiedpush.Connector1') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(
    String interface,
    String name,
    DBusValue value,
  ) async {
    if (interface == 'org.unifiedpush.Connector1') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }
}
