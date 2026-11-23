import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calculation.dart';

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

  Future<void> saveTdeeProfile({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String diabetesType,
    required String activityLevel,
    required String healthInformation,
  }) async {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    await _db.collection('users').doc(uid).set({
      'age': age,
      'gender': gender,
      'height': heightCm,
      'weight': weightKg,
      'diabetesType': diabetesType,
      'activityLevel': activityLevel,
      'healthInformation': healthInformation,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveCalculationHistory(
    TdeeCalculationResult result,
  ) async {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    await _db
        .collection('users')
        .doc(uid)
        .collection('calculation_history')
        .add({
      'bmr': result.bmr,
      'tdee': result.tdee,
      'bmi': result.bmi,
      'carbs': result.carbs,
      'protein': result.protein,
      'fat': result.fat,
      'calculatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<TdeeCalculationResult?> getLatestCalculationHistory() async {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('calculation_history')
        .orderBy('calculatedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final data = snapshot.docs.first.data();

    return TdeeCalculationResult(
      bmr: (data['bmr'] as num).toDouble(),
      tdee: (data['tdee'] as num).toDouble(),
      bmi: (data['bmi'] as num).toDouble(),
      carbs: (data['carbs'] as num).toDouble(),
      protein: (data['protein'] as num).toDouble(),
      fat: (data['fat'] as num).toDouble(),
    );
  }
}