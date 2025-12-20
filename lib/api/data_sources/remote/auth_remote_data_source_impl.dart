import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../data/data_sources/remote/auth_remote_data_source.dart';
import '../../../data/models/user_model.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;
      String? fullName;
      String? age;
      String? role;

      try {
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          fullName = data?['fullName'] as String?;
          age = data?['age'] as String?;
          role = data?['role'] as String?;
        }
      } catch (_) {
        // ignore Firestore read errors
      }

      return UserModel.fromFirebaseUser(
        firebaseUser,
        fullName: fullName,
        age: age,
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception(
        'An unexpected error occurred during login: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String age,
    required String role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;
      final uid = firebaseUser.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'age': age,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (fullName.isNotEmpty) {
        await firebaseUser.updateDisplayName(fullName);
      }

      return UserModel.fromFirebaseUser(
        firebaseUser,
        fullName: fullName,
        age: age,
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception(
        'An unexpected error occurred during registration: ${e.toString()}',
      );
    }
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'email-already-in-use':
        return Exception('The account already exists for that email.');
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided for that user.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many requests. Try again later.');
      case 'operation-not-allowed':
        return Exception('Signing in with Email and Password is not enabled.');
      case 'network-request-failed':
        return Exception(
          'Network error. Please check your internet connection.',
        );
      case 'channel-error':
        return Exception(
          'Firebase configuration error. Please restart the app.',
        );
      default:
        return Exception('Authentication failed: ${e.message ?? e.code}');
    }
  }
}
