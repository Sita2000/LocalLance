import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/user_preferences_service.dart';
import '../../db/firebase/user.dart';
import '../../db/models/user_model.dart';

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

// Provider for UserDatabase
final userDatabaseProvider = Provider<UserDatabase>((ref) {
  return UserDatabase();
});

// Auth controller for login, registration, and profile management
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final UserPreferencesService _prefsService = UserPreferencesService();
  final UserDatabase _userDatabase = UserDatabase();
  
  AuthController() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
  }

  // Handle Google sign-in with role selection
  Future<bool> handleGoogleSignInWithRole(User firebaseUser, String role) async {
    try {
      // Use the UserDatabase method to handle Google user with role
      await _userDatabase.handleGoogleUser(firebaseUser, role);
      return true;
    } catch (e) {
      print('Error handling Google sign in with role: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // After signing in, determine the user role and save it
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _saveUserRole(uid);
      }
      
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
    String role,
  ) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      if (userCredential.user != null) {
        final appUser = AppUser(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          role: role,
          profileImageUrl: userCredential.user!.photoURL,
        );
        
        // Create user in unified users collection
        await _userDatabase.createUser(appUser);
        
        // Save role in preferences
        await _prefsService.saveUserRole(role);
        await _prefsService.saveUserId(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      // Clear local user data from preferences
      await _prefsService.clearUserData();
      
      // Sign out from Google if it was used for sign-in
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      
      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Helper method to save user role
  Future<void> _saveUserRole(String uid) async {
    try {
      // Get user from unified users collection
      final user = await _userDatabase.getUser(uid);
      
      if (user != null && user.role.isNotEmpty) {
        // User exists and has a role, save it
        await _prefsService.saveUserRole(user.role);
        await _prefsService.saveUserId(uid);
        return;
      }
      
      // If user document not found or role is empty
      print('User role not found for user: $uid');
    } catch (e) {
      print('Error determining user role: $e');
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
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
      }
      
      // Get the existing user
      final appUser = await _userDatabase.getUser(user.uid);
      if (appUser != null) {
        // Update user in main users collection
        final updatedUser = AppUser(
          uid: appUser.uid,
          name: displayName ?? appUser.name,
          email: appUser.email,
          role: appUser.role,
          phone: appUser.phone,
          profileImageUrl: photoURL ?? appUser.profileImageUrl,
        );
        
        await _userDatabase.updateUser(updatedUser);
        
        // Add additional data if provided
        if (additionalData != null && additionalData.isNotEmpty) {
          Map<String, dynamic> updateData = {
            'name': displayName ?? appUser.name,
            'profileImageUrl': photoURL ?? appUser.profileImageUrl,
            ...additionalData
          };
          
          await _userDatabase.usersCollection.doc(user.uid).update(updateData);
        }
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

      // Delete from users collection
      await _userDatabase.deleteUser(user.uid);
      
      // Clear shared preferences data
      await _prefsService.clearUserData();
      
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
