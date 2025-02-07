/// A registration request may fail for different reasons
enum FailedReason {
  /// This is a generic error type, you can try to register again directly.
  internalError,
  /// The registration failed because of missing network connection, try again when network is back.
  network,
  /// The distributor requires a user action to work. For instance, the distributor
  /// may be log out of the push server and requires the user to log in. The user
  /// must interact with the distributor or sending a new registration will fail again.
  actionRequired,
  /// The distributor requires a VAPID key and you didn't provide one during registration
  vapidRequired
}