import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'package:dentex_clean/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:dentex_clean/data/models/user_model.dart';
import 'package:dentex_clean/data/models/supplier_model.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
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

      final UserCredential userCredential = await auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) throw Exception("Firebase authentication failed.");

      final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
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
        await firestore.collection('users').doc(firebaseUser.uid).set(userData);
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
    String? clinicName,
    String? allergies,
    String? medicalInsurance,
    String? companyId,
    String? address,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      final currentUser = auth.currentUser;
      bool useSecondaryApp = currentUser != null;

      UserCredential credential;
      FirebaseFirestore firestoreToUse = firestore;

      if (useSecondaryApp) {
        final String appName = 'TempReg_${DateTime.now().millisecondsSinceEpoch}';
        secondaryApp = await Firebase.initializeApp(
          name: appName,
          options: Firebase.app().options,
        );
        
        credential = await FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        firestoreToUse = FirebaseFirestore.instanceFor(app: secondaryApp);
      } else {
        credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final firebaseUser = credential.user!;
      final uid = firebaseUser.uid;
      final normalizedRole = role.trim().toLowerCase();

      final Map<String, dynamic> userData = {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'age': age,
        'role': normalizedRole,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
        'companyId': companyId,
        'address': address,
      };

      if (normalizedRole == 'doctor') {
        userData['speciality'] = speciality ?? '';
        userData['rank'] = rank ?? '';
        userData['experience'] = experience ?? '';
        userData['education'] = education ?? '';
        userData['certificates'] = certificates ?? '';
        userData['clinicName'] = clinicName ?? '';
      } else if (normalizedRole == 'patient') {
        userData['allergies'] = allergies ?? '';
        userData['medicalInsurance'] = medicalInsurance ?? '';
      } else if (normalizedRole == 'receptionist' || normalizedRole == 'assistant' || normalizedRole == 'nurse') {
        if (currentUser != null) {
          userData['assignedDoctorId'] = currentUser.uid;
          userData['assignedDoctorName'] = currentUser.displayName ?? 'Doctor';
          
          // SYNC: Fetch the current user's (Doctor/Admin) clinic name to sync to staff
          final docSnap = await firestore.collection('users').doc(currentUser.uid).get();
          if (docSnap.exists) {
            userData['clinicName'] = docSnap.data()?['clinicName'] ?? '';
          }
        }
      }

      await firestoreToUse.collection('users').doc(uid).set(userData);

      if (normalizedRole == 'supplier') {
        await firestoreToUse.collection('suppliers').doc(uid).set({
          'name': fullName,
          'companyId': companyId ?? 'Unknown',
          'email': email,
          'phone': phoneNumber,
          'address': address ?? '',
        });
      }

      if (fullName.isNotEmpty) {
        await firebaseUser.updateDisplayName(fullName);
      }

      return UserModel.fromFirestore(userData, uid);
      
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Cloud Firestore Permission Denied: Staff registration failed due to security rules.');
      }
      throw Exception('Firestore Error: ${e.message}');
    } catch (e) {
      throw Exception('Registration Failed: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (secondaryApp != null) {
        await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
      }
    }
  }

  @override
  Future<UserModel> getUserData(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data()!, uid);
    }
    return UserModel(id: uid, fullName: "New User", role: "patient");
  }

  @override
  Future<void> updatePatientFinancials(String uid, double totalToPay, double totalPaid) async {
    await firestore.collection('users').doc(uid).set({
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
      await firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      });
      
      final currentUser = auth.currentUser;
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
      User? user = auth.currentUser;
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
      await _firestore.collection('suppliers').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user record: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getAllDoctors() async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getAllPatients() async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch patients: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getAllSuppliers() async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'supplier')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch suppliers: ${e.toString()}');
    }
  }

  @override
  Future<void> addSupplier(SupplierModel supplier) async {
    await firestore.collection('suppliers').doc(supplier.id).set(supplier.toFirestore());
  }

  @override
  Future<List<SupplierModel>> getSuppliersByCompany(String companyId) async {
    final querySnapshot = await firestore
        .collection('suppliers')
        .where('companyId', isEqualTo: companyId)
        .get();

    return querySnapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<List<UserModel>> getDoctorsStream() {
    return firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
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
