import 'package:unifiedpush_platform_interface/data/public_key_set.dart';

class PushEndpoint {
  final String url;
  final PublicKeySet? pubKeySet;
  PushEndpoint(this.url, this.pubKeySet);
}