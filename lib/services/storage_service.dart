import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'app_config.dart';

/// Uploads report/validation photographs to Firebase Storage and returns a
/// public download URL to save on the corresponding Firestore document.
class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;
  Future<String> uploadHazardPhoto({
    required File file,
    required String reportId,
  }) async {
    if (AppConfig.useMockBackend) {
      // No real backend configured yet — keep the local file path so the
      // UI can still preview the image during the prototype demo.
      return file.path;
    }
    final ref = _storage.ref().child('reports/$reportId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
