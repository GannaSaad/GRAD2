import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageUtils {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL.
  static Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      print('📤 Starting upload to Firebase Storage...');
      print('📁 Folder: $folder');
      print('📄 File path: ${imageFile.path}');
      print('📏 File size: ${imageFile.lengthSync()} bytes');
      
      // Create a unique filename
      String fileName = const Uuid().v4();
      
      // Reference to the location in storage
      Reference ref = _storage.ref().child(folder).child('$fileName.jpg');
      print('🔗 Storage reference: ${ref.fullPath}');

      // Upload task with metadata
      UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('⏳ Upload progress: ${progress.toStringAsFixed(1)}%');
      });
      
      // Wait for completion
      TaskSnapshot snapshot = await uploadTask;
      print('✅ Upload completed!');
      print('📊 Total bytes: ${snapshot.totalBytes}');
      
      // Get and return the download URL
      String downloadURL = await snapshot.ref.getDownloadURL();
      print('🔗 Download URL: $downloadURL');
      
      return downloadURL;
    } catch (e, stackTrace) {
      print("❌ Firebase Storage Error: $e");
      print("Stack trace: $stackTrace");
      rethrow; // Re-throw to let calling code handle it
    }
  }
}
