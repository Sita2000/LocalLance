import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Provider to access the current authenticated user (or null if not authenticated)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider for Google Sign In functionality
final googleSignInProvider = Provider<Future<UserCredential?> Function()>((ref) {
  return () async {
    try {
      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // If user cancels the sign-in flow
      if (googleUser == null) return null;
      
      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in with credential and return UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // Handle sign-in errors
      print('Google sign in error: $e');
      return null;
    }
  };
});

// Auth controller for login, registration, and profile management
class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String name,
    bool isRecruiter,
  ) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      final uid = userCredential.user!.uid;
      final collectionPath = isRecruiter ? 'recruiters' : 'freelancers';
      
      await FirebaseFirestore.instance.collection(collectionPath).doc(uid).set({
        'name': name,
        'email': email,
        'isRecruiter': isRecruiter,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Update user profile (display name, photo, etc.)
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Update Auth profile
      if (displayName != null || photoURL != null) {
        await user.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
      }
      
      // Update Firestore data if needed
      if (additionalData != null && additionalData.isNotEmpty) {
        final uid = user.uid;
        
        // Determine if user is a recruiter or freelancer
        final recruiterDoc = await FirebaseFirestore.instance
            .collection('recruiters')
            .doc(uid)
            .get();
            
        final collectionPath = recruiterDoc.exists ? 'recruiters' : 'freelancers';
        
        await FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(uid)
            .update(additionalData);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      
      await user.updatePassword(newPassword);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // First delete the user document from Firestore
      final uid = user.uid;
      
      // Check both collections to find the user document
      final recruiterDoc = await FirebaseFirestore.instance
          .collection('recruiters')
          .doc(uid)
          .get();
          
      if (recruiterDoc.exists) {
        await FirebaseFirestore.instance
            .collection('recruiters')
            .doc(uid)
            .delete();
      } else {
        // Check freelancers collection
        final freelancerDoc = await FirebaseFirestore.instance
            .collection('freelancers')
            .doc(uid)
            .get();
            
        if (freelancerDoc.exists) {
          await FirebaseFirestore.instance
              .collection('freelancers')
              .doc(uid)
              .delete();
        }
      }
      
      // Then delete the authentication record
      await user.delete();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

// Provider for the auth controller
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  return AuthController();
});
