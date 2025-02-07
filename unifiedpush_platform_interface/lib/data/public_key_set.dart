/// Contains Web Push (public) keys information necessary for the application server
/// to encrypt notification for this instance, following [RFC8291](https://www.rfc-editor.org/rfc/rfc8291)
class PublicKeySet {
  /// P-256 Public key, in uncompressed format, base64url encoded without padding.
  final String pubKey;
  /// Auth secret, base64url encoded without padding.
  final String auth;
  PublicKeySet(this.pubKey, this.auth);
}