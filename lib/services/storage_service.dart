import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'app_config.dart';


class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;
  Future<String> uploadHazardPhoto({
    required File file,
    required String reportId,
  }) async {
    if (AppConfig.useMockBackend) {
      return file.path;
    }
    final ref = _storage.ref().child('reports/$reportId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
