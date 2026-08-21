import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Web rewrite of the mobile StorageService. Mobile uploads via dart:io
/// File + flutter_image_compress, neither of which work on web — this
/// uploads raw bytes (from XFile.readAsBytes(), which works cross-platform
/// including web) via putData instead of putFile, and skips compression
/// (image_picker's own imageQuality already re-encodes on web).
class StorageService {
  FirebaseStorage? fs;

  Future<String> uploadImageToStorage({
    required Uint8List bytes,
    required String fileName,
    required String folderName,
  }) async {
    try {
      final time =
          '${DateTime.now().minute}-${DateTime.now().second}-${DateTime.now().millisecond}-${DateTime.now().microsecond}';
      fs = FirebaseStorage.instance;
      final ref = fs!.ref().child('$folderName/$time-$fileName');
      final upload = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await upload.ref.getDownloadURL();
    } catch (e) {
      throw Exception(e);
    }
  }

  // Web rewrite of mobile's SaveFiles.savePdf (lib/src/app/utils/services/
  // save_files.dart) — mobile writes the generated PdfDocument to a local
  // temp file first (path_provider) purely so it has a File to hand
  // uploadFileToStorage; putData needs no such intermediate step, so the
  // whole temp-file dance (and the wrapper class) drops out entirely.
  Future<String> uploadPdfToStorage({
    required Uint8List bytes,
    required String fileName,
    required String folderName,
  }) async {
    try {
      fs = FirebaseStorage.instance;
      final ref = fs!.ref().child('$folderName/$fileName');
      final upload = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'application/pdf'),
      );
      return await upload.ref.getDownloadURL();
    } catch (e) {
      throw Exception(e);
    }
  }

  //Will delete the file from storage
  Future<bool> deleteItemFromStorage(
      {String? url, String? uid, String? folder}) async {
    try {
      // Validate input
      if (url == null || url.isEmpty) {
        return false;
      }

      // Validate that the URL is a valid Firebase Storage URL
      if (!url.contains('firebasestorage.googleapis.com')) {
        return false;
      }

      final fs = FirebaseStorage.instance;

      // Use refFromURL and handle the operation properly
      await fs.refFromURL(url).delete();

      // If we reach here, deletion was successful

      return true;
    } on FirebaseException catch (e) {
      // Handle specific Firebase errors
      if (e.code == 'object-not-found') {
        return false; // Or throw an exception if you prefer
      } else {
        rethrow; // Re-throw other Firebase exceptions
      }
    } catch (e) {
      rethrow;
    }
  }
}
