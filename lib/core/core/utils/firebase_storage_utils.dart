import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageUtils {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL.
  static Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      // Create a unique filename
      String fileName = const Uuid().v4();
      
      // Reference to the location in storage
      Reference ref = _storage.ref().child(folder).child('$fileName.jpg');

      // Upload task
      UploadTask uploadTask = ref.putFile(imageFile);
      
      // Wait for completion
      TaskSnapshot snapshot = await uploadTask;
      
      // Get and return the download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Firebase Storage Error: $e");
      return null;
    }
  }
}
