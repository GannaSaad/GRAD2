import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'package:dentex_clean/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:dentex_clean/data/models/user_model.dart';

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
    FirebaseApp? secondaryApp;
    try {
      UserCredential credential;
      final currentUser = _firebaseAuth.currentUser;
      
      bool useSecondaryApp = currentUser != null && (
        role.toLowerCase() == 'receptionist' || 
        role.toLowerCase() == 'assistant' || 
        role.toLowerCase() == 'doctor'
      );

      if (useSecondaryApp) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
          options: Firebase.app().options,
        );
        credential = await FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

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
      } else if (normalizedRole == 'receptionist' || normalizedRole == 'assistant') {
        if (currentUser != null) {
          userData['assignedDoctorId'] = currentUser.uid;
          userData['assignedDoctorName'] = currentUser.displayName ?? 'Doctor';
        }
      }

      await _firestore.collection('users').doc(uid).set(userData);

      if (fullName.isNotEmpty) {
        await firebaseUser.updateDisplayName(fullName);
      }

      return await getUserData(uid);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
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
        assignedDoctorId: data['assignedDoctorId'],
        assignedDoctorName: data['assignedDoctorName'],
        totalToPay: (data['totalToPay'] as num?)?.toDouble(),
        totalPaid: (data['totalPaid'] as num?)?.toDouble(),
      );
    }
    return UserModel(id: uid, fullName: "New Patient", role: "patient", totalToPay: 0, totalPaid: 0);
  }

  @override
  Future<void> updatePatientFinancials(String uid, double totalToPay, double totalPaid) async {
    await _firestore.collection('users').doc(uid).set({
      'totalToPay': totalToPay,
      'totalPaid': totalPaid,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      });
      
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        await currentUser.updateDisplayName(fullName);
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) throw Exception("User session not found.");

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete doctor record: ${e.toString()}');
    }
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

  @override
  Future<List<UserModel>> getAllPatients() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
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
                allergies: doc.data()['allergies'],
                medicalInsurance: doc.data()['medicalInsurance'],
                assignedDoctorId: doc.data()['assignedDoctorId'],
                assignedDoctorName: doc.data()['assignedDoctorName'],
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch patients: ${e.toString()}');
    }
  }

  @override
  Stream<List<UserModel>> getDoctorsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) => snapshot.docs
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
            .toList());
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password': return Exception('The password provided is too weak.');
      case 'email-already-in-use': return Exception('The account already exists for that email.');
      case 'user-not-found': return Exception('No user found for that email.');
      case 'wrong-password': return Exception('Current password provided is incorrect.');
      case 'invalid-email': return Exception('The email address is not valid.');
      case 'invalid-credential': return Exception('The credentials provided are incorrect or expired.');
      default: return Exception('Authentication failed: ${e.message ?? e.code}');
    }
  }
}
