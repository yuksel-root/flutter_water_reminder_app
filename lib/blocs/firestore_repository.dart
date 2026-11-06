import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore,
      _auth = auth;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;

  String get userId {
    final user = auth.currentUser;
    if (user == null) {
      throw StateError('User is not signed in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> userCollection(String name) {
    return firestore.collection('users').doc(userId).collection(name);
  }
}
