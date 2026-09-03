import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Firebase Storage Service handling media attachment uploads (images, documents, audio, avatars).
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Prompts user to pick a file (image, video, document) and uploads it to Firebase Storage.
  /// Returns a map with download URL and file metadata, or null if canceled.
  Future<Map<String, dynamic>?> pickAndUploadAttachment({
    required String conversationId,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        withData: true, // Loads bytes into memory for cross-platform support (Web & Mobile)
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedFileName = '${timestamp}_${file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      final storagePath = 'conversations/$conversationId/attachments/$sanitizedFileName';

      final ref = _storage.ref().child(storagePath);

      final metadata = SettableMetadata(
        contentType: _guessContentType(file.extension ?? ''),
        customMetadata: {
          'originalName': file.name,
          'sizeBytes': file.size.toString(),
        },
      );

      final uploadTask = ref.putData(bytes, metadata);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress(progress);
          }
        });
      }

      final completedSnapshot = await uploadTask;
      final downloadUrl = await completedSnapshot.ref.getDownloadURL();

      return {
        'downloadUrl': downloadUrl,
        'fileName': file.name,
        'sizeBytes': file.size,
        'extension': file.extension,
      };
    } catch (e) {
      if (kDebugMode) {
        print('StorageService.pickAndUploadAttachment error: $e');
      }
      rethrow;
    }
  }

  /// Prompts user to pick an image and uploads it as their avatar in Firebase Storage.
  /// Returns the download URL or null if canceled.
  Future<String?> pickAndUploadAvatar({
    required String userId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return null;

      final ext = (file.extension ?? 'jpg').toLowerCase();
      final storagePath = 'users/$userId/avatar/profile_$userId.$ext';

      final ref = _storage.ref().child(storagePath);
      final metadata = SettableMetadata(
        contentType: _guessContentType(ext),
      );

      final uploadTask = ref.putData(bytes, metadata);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress(progress);
          }
        });
      }

      final completedSnapshot = await uploadTask;
      return await completedSnapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('StorageService.pickAndUploadAvatar error: $e');
      }
      rethrow;
    }
  }

  /// Direct byte upload to a custom storage path.
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: contentType);
    final task = await ref.putData(bytes, metadata);
    return await task.ref.getDownloadURL();
  }

  String _guessContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp3':
      case 'm4a':
      case 'wav':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }
}
