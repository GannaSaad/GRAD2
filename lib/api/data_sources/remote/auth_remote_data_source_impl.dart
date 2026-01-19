import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../data/data_sources/remote/auth_remote_data_source.dart';
import '../../../data/models/user_model.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
      return await getUserData(firebaseUser.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during login: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception("Google Sign-In was cancelled.");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) throw Exception("Firebase authentication failed.");

      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) {
        final userData = {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'fullName': firebaseUser.displayName ?? '',
          'age': '',
          'role': 'patient',
          'phoneNumber': firebaseUser.phoneNumber ?? '',
          'gender': '',
          'createdAt': FieldValue.serverTimestamp(),
          'allergies': '',
          'medicalInsurance': '',
        };
        await _firestore.collection('users').doc(firebaseUser.uid).set(userData);
      }

      return await getUserData(firebaseUser.uid);
    } catch (e) {
      throw Exception('Google Sign-In failed: ${e.toString()}');
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
    String? rank,
    String? experience,
    String? education,
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

      final normalizedRole = role.trim().toLowerCase();
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

      if (normalizedRole == 'doctor') {
        userData['speciality'] = speciality ?? '';
        userData['rank'] = rank ?? '';
        userData['experience'] = experience ?? '';
        userData['education'] = education ?? '';
        userData['certificates'] = certificates ?? '';
      } else if (normalizedRole == 'patient') {
        userData['allergies'] = allergies ?? '';
        userData['medicalInsurance'] = medicalInsurance ?? '';
      }

      await _firestore.collection('users').doc(uid).set(userData);

      if (normalizedRole == 'doctor' || normalizedRole == 'patient') {
        await firebaseUser.sendEmailVerification();
      }

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
        rank: rank,
        experience: experience,
        education: education,
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

  @override
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      return UserModel(
        id: uid,
        email: data['email'],
        fullName: data['fullName'],
        age: data['age'],
        role: data['role'],
        phoneNumber: data['phoneNumber'],
        gender: data['gender'],
        speciality: data['speciality'],
        rank: data['rank'],
        experience: data['experience'],
        education: data['education'],
        certificates: data['certificates'],
        allergies: data['allergies'],
        medicalInsurance: data['medicalInsurance'],
      );
    }
    throw Exception("User data not found in Firestore");
  }

  @override
  Future<List<UserModel>> getAllDoctors() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel(
                id: doc.id,
                email: doc.data()['email'],
                fullName: doc.data()['fullName'],
                age: doc.data()['age'],
                role: doc.data()['role'],
                phoneNumber: doc.data()['phoneNumber'],
                gender: doc.data()['gender'],
                speciality: doc.data()['speciality'],
                rank: doc.data()['rank'],
                experience: doc.data()['experience'],
                education: doc.data()['education'],
                certificates: doc.data()['certificates'],
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors: ${e.toString()}');
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
