import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  Future<void> saveUserProfile({
    required String name,
    required String email,
  }) async {
    final uid = currentUserId;

    print('Firestore: Saving user profile...');
    print('Firestore: Current UID = $uid');

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Firestore: User profile saved successfully!');
    } catch (e) {
      print('Firestore ERROR: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data();
  }



}