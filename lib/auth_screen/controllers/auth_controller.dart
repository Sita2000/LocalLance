import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final googleSignInProvider = Provider((ref) => ref.watch(authServiceProvider).signInWithGoogle);
final signOutProvider = Provider((ref) => ref.watch(authServiceProvider).signOut);
