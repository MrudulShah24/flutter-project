// lib/services/media_service.dart

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<PlatformFile?> pickFileFromGallery() async {
    if (await Permission.storage.request().isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
      );
      return result?.files.single;
    }
    return null;
  }

  Future<XFile?> pickVideoFromGallery() async {
    if (await Permission.storage.request().isGranted) {
      return await _picker.pickVideo(source: ImageSource.gallery);
    }
    return null;
  }

  Future<XFile?> pickVideoFromCamera() async {
    if (await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted) {
      return await _picker.pickVideo(source: ImageSource.camera);
    }
    return null;
  }
}