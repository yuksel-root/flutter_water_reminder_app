import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User is not signed in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> userCollection(String name) {
    return _firestore.collection('users').doc(userId).collection(name);
  }
}
