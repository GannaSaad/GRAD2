import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthDebug {
  static Future<void> debugFirebaseAuth() async {
    try {
      print('=== Firebase Auth Debug ===');
      
      // Check Firebase initialization
      print('Firebase apps: ${Firebase.apps.length}');
      if (Firebase.apps.isNotEmpty) {
        print('Firebase app name: ${Firebase.app().name}');
        print('Firebase options: ${Firebase.app().options.projectId}');
      }
      
      // Check Firebase Auth instance
      final auth = FirebaseAuth.instance;
      print('Firebase Auth instance: ${auth.hashCode}');
      print('Current user: ${auth.currentUser?.uid ?? 'null'}');
      
      // Test a simple auth operation
      print('Testing auth state changes...');
      auth.authStateChanges().listen((User? user) {
        print('Auth state changed: ${user?.uid ?? 'null'}');
      });
      
      print('=== Debug Complete ===');
    } catch (e, stackTrace) {
      print('=== Firebase Auth Debug Error ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  static Future<void> testSimpleLogin(String email, String password) async {
    try {
      print('=== Testing Simple Login ===');
      print('Email: $email');
      
      final auth = FirebaseAuth.instance;
      print('Auth instance ready');
      
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Login successful: ${credential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception:');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('Plugin: ${e.plugin}');
    } catch (e, stackTrace) {
      print('General Exception: $e');
      print('Stack trace: $stackTrace');
    }
  }
}