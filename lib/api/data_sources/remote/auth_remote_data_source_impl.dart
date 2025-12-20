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
      
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email,
          fullName: data['fullName'],
          age: data['age'],
          role: data['role'],
          phoneNumber: data['phoneNumber'],
          gender: data['gender'],
          speciality: data['speciality'],
          certificates: data['certificates'],
          allergies: data['allergies'],
          medicalInsurance: data['medicalInsurance'],
        );
      }

      return UserModel.fromFirebaseUser(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during login: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String age,
    required String role,
    required String phoneNumber,
    required String gender,
    String? speciality,
    String? certificates,
    String? allergies,
    String? medicalInsurance,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;
      final uid = firebaseUser.uid;

      final userData = {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'age': age,
        'role': role,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (role == 'doctor') {
        userData['speciality'] = speciality ?? '';
        userData['certificates'] = certificates ?? '';
      } else {
        userData['allergies'] = allergies ?? '';
        userData['medicalInsurance'] = medicalInsurance ?? '';
      }

      await _firestore.collection('users').doc(uid).set(userData);

      if (fullName.isNotEmpty) {
        await firebaseUser.updateDisplayName(fullName);
      }

      return UserModel(
        id: uid,
        email: email,
        fullName: fullName,
        age: age,
        role: role,
        phoneNumber: phoneNumber,
        gender: gender,
        speciality: speciality,
        certificates: certificates,
        allergies: allergies,
        medicalInsurance: medicalInsurance,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during registration: ${e.toString()}');
    }
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password': return Exception('The password provided is too weak.');
      case 'email-already-in-use': return Exception('The account already exists for that email.');
      case 'user-not-found': return Exception('No user found for that email.');
      case 'wrong-password': return Exception('Wrong password provided for that user.');
      case 'invalid-email': return Exception('The email address is not valid.');
      default: return Exception('Authentication failed: ${e.message ?? e.code}');
    }
  }
}
