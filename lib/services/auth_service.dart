import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gravity_rewards_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login timestamp
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
        
        // Fetch user data
        return await getUserData(userCredential.user!.uid);
      }
      
      return null;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Create user in Firestore
        final UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          name: name,
          points: 0,
          rewardHistory: [],
          activityHistory: [],
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toJson());
        
        return newUser;
      }
      
      return null;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        
        if (!userDoc.exists) {
          // Create new user in Firestore
          final UserModel newUser = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            name: userCredential.user!.displayName ?? 'User',
            profileImageUrl: userCredential.user!.photoURL,
            points: 0,
            rewardHistory: [],
            activityHistory: [],
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          
          await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toJson());
          
          return newUser;
        } else {
          // Update last login timestamp
          await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastLoginAt': DateTime.now().toIso8601String(),
          });
          
          // Fetch user data
          return await getUserData(userCredential.user!.uid);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _secureStorage.delete(key: 'user_token');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = 
          await _firestore.collection('users').doc(userId).get() as DocumentSnapshot<Map<String, dynamic>>;
      
      if (doc.exists) {
        return UserModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      
      return null;
    } catch (e) {
      debugPrint('Get user data error: $e');
      return null;
    }
  }

  // Update user profile
  Future<UserModel?> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      
      await _firestore.collection('users').doc(userId).update(updateData);
      
      return await getUserData(userId);
    } catch (e) {
      debugPrint('Update user profile error: $e');
      rethrow;
    }
  }
} 