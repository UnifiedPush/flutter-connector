import 'dart:typed_data';

/// Contains the push message. It has been correctly decrypted if [decrypted] is `true`.
class PushMessage {
  /// Content of the push message.
  final Uint8List content;
  /// Whether it has been correctly decrypted.
  final bool decrypted;
  PushMessage(this.content, this.decrypted);
}