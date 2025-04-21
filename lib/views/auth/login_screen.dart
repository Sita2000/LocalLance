import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../auth_screen/controllers/user_controller.dart';
import '../../db/models/user_model.dart';
import '../../../auth_screen/controllers/auth_controller.dart';

class LoginScreenV2 extends ConsumerWidget {
  final logger = Logger();
  LoginScreenV2({super.key});

  void _handleGoogleSignIn(BuildContext context, WidgetRef ref, String role) async {
    final signIn = ref.read(googleSignInProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final cred = await signIn();
    if (cred != null && cred.user != null) {
      final user = cred.user!;
      // Check if user exists in Firestore
      final existing = await ref.read(userDatabaseProvider).getUser(user.uid);
      if (existing == null) {
        // Create new user in Firestore
        final appUser = AppUser(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          role: role,
          profileImageUrl: user.photoURL,
        );
        await userNotifier.createUser(appUser);
      } else if (existing.role != role) {
        // Optionally handle role mismatch
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Account already exists as ${existing.role}')),
        );
        return;
      }
      logger.d('User signed in: ${user.displayName}');
      logger.d("User Role: $role");
      if(!context.mounted){
        // show snackbar
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('User not mounted')),
        );
        return;
      }
      if(role == 'job_recruiter') {
        // Navigate to recruiter-specific screen
        context.go('/freelancer/dashboard');
        return;
      } else if(role == 'freelancer') {
        // Navigate to freelancer-specific screen
        context.go('/freelancer/dashboard');
        return;
      }
      // Navigate to home or role-specific screen
      context.go('/home');
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Google sign-in failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  minHeight: screenSize.height - 40, // Account for padding
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Login title
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        Text(
                          'Access your account for personalized features',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // Continue with Google text
                        Text(
                          'Continue with Google',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Freelancer button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleGoogleSignIn(context, ref, 'freelancer'),
                            icon: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                              height: 24,
                              width: 24,
                            ),
                            label: Text(
                              'As a freelancer',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B5B84),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Recruiter button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleGoogleSignIn(context, ref, 'job_recruiter'),
                            icon: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                              height: 24,
                              width: 24,
                            ),
                            label: Text(
                              'As a Recruiter',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Sign up text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
