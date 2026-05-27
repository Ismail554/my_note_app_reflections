import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final UserService instance = UserService._internal();
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static UserService get to => instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateUserProfileName(String uid, String name) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
    });
  }
}
