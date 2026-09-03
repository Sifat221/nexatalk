/// NexaTalk Application Configuration.
/// Decoupled from custom Express/Socket.IO backend and fully backed by Firebase.
class AppConfig {
  /// Active Firebase Project ID
  static const String firebaseProjectId = 'nexa-talk-169ff';

  /// Primary Cloud Storage Bucket
  static const String storageBucket = 'nexa-talk-169ff.firebasestorage.app';

  /// STUN Server for WebRTC / VoIP Calls
  static const String stunServer = 'stun:stun.l.google.com:19302';
}
