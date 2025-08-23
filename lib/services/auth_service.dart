import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          displayName: displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
