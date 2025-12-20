import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseTest {
  static Future<bool> testFirebaseConnection() async {
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        return false;
      }
      
      // Test Firebase Auth instance
      final auth = FirebaseAuth.instance;
      
      // Check current user (this should not throw an error)
      final currentUser = auth.currentUser;
      
      print('Firebase connection test passed. Current user: ${currentUser?.uid ?? 'No user'}');
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
}