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

  // Check if user exists by email (alternative approach)
  Future<bool> checkUserExists(String email) async {
    try {
      // Try to send password reset email as a way to check if user exists
      // This is a workaround since fetchSignInMethodsForEmail is deprecated
      await _auth.sendPasswordResetEmail(email: email);
      return true; // If no exception, user exists
    } on FirebaseAuthException catch (e) {
      // Check specific error codes
      if (e.code == 'user-not-found') {
        return false;
      }
      // For other errors, assume user exists to avoid security issues
      return true;
    } catch (e) {
      // For any other error, assume user exists
      return true;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email address.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Please enter a valid email address.');
      } else {
        throw Exception('Failed to send password reset email. Please try again.');
      }
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
