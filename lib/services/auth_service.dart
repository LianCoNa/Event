import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    bool isAdmin = false,
  }) async {
    _auth.setLanguageCode('es');

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'isAdmin': isAdmin,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    _auth.setLanguageCode('es');

    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _auth.setLanguageCode('es');

    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> currentUserDocStream() {
    final user = _auth.currentUser!;
    return _db.collection('users').doc(user.uid).snapshots();
  }
}