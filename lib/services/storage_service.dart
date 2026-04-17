import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadEventImage({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';

    final ref = _storage.ref().child(
          'events/$userId/${DateTime.now().millisecondsSinceEpoch}.$extension',
        );

    final metadata = SettableMetadata(
      contentType: extension == 'png' ? 'image/png' : 'image/jpeg',
    );

    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }
}