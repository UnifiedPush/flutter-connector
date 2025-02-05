import 'dart:typed_data';

class PushMessage {
  final Uint8List content;
  final bool decrypted;
  PushMessage(this.content, this.decrypted);
}