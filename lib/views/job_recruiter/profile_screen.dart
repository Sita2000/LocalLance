import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mylocallance/views/job_recruiter/edit_profile_screen.dart';
import 'package:mylocallance/views/job_recruiter/myjob_screen.dart';
import '../../auth_screen/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider to fetch recruiter profile data from Firestore
final recruiterProfileProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('recruiters').doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  } catch (e) {
    throw Exception('Failed to load recruiter profile: $e');
  }
});

class RecruiterProfileScreen extends ConsumerWidget {
  static const String routePath = "/recruiter_profile";
  static const String routeName = "Recruiter Profile";
  const RecruiterProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.of(context).size.width;
    final double profileImageSize = width * 0.25;
    final double iconSize = width * 0.06;

    // Get current authenticated user
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You are not logged in",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text("Go to Login"),
                  ),
                ],
              ),
            ),
          );
        }

        // Fetch additional recruiter profile data
        final profileAsync = ref.watch(recruiterProfileProvider(user.uid));

        return Scaffold(
          body: Center(
            child: profileAsync.when(
              data: (profileData) {
                // Combine Firebase Auth user data with Firestore profile data
                final String displayName = user.displayName ?? profileData?['name'] ?? 'Unnamed Recruiter';
                final String email = user.email ?? 'No email';
                final int hireCount = profileData?['hireCount'] ?? 0;
                final DateTime createdAt = user.metadata.creationTime ?? DateTime.now();
                final int monthsActive = DateTime.now().difference(createdAt).inDays ~/ 30;
                
                return Container(
                  constraints: const BoxConstraints(
                    maxWidth: 480,
                    minWidth: 320,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Section
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C3A4B),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 8, bottom: 24,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            // Profile image - use Firebase image if available, otherwise default
                            CircleAvatar(
                              radius: profileImageSize / 2,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _getProfileImage(user.photoURL, profileData?['photoURL']),
                              child: (user.photoURL == null && profileData?['photoURL'] == null)
                                ? Icon(
                                    Icons.person,
                                    size: profileImageSize / 2,
                                    color: Colors.grey[600],
                                  )
                                : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              displayName,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Recruiter",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified, color: Colors.amber, size: iconSize),
                                const SizedBox(width: 4),
                                Text(
                                  "$monthsActive ${monthsActive == 1 ? 'month' : 'months'}",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.star, color: Colors.lightBlueAccent, size: iconSize),
                                const SizedBox(width: 4),
                                Text(
                                  "$hireCount ${hireCount == 1 ? 'hire' : 'hires'}",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.pushNamed(EditProfileScreen.routeName);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2C3A4B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                textStyle: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                elevation: 2,
                              ),
                              child: const Text("Edit Profile"),
                            ),
                          ],
                        ),
                      ),
                      // Action Cards Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Column(
                          children: [
                            _ActionCard(
                              icon: Icons.list_alt_rounded,
                              label: "Manage your jobs",
                              onTap: () => context.goNamed(MyJobScreen.routeName),
                            ),
                            const SizedBox(height: 16),
                            _ActionCard(
                              icon: Icons.lock_rounded,
                              label: "Change password",
                              onTap: () {
                                // Show change password dialog
                                _showChangePasswordDialog(context, ref);
                              },
                            ),
                            const SizedBox(height: 16),
                            _ActionCard(
                              icon: Icons.logout_rounded,
                              label: "Logout",
                              onTap: () async {
                                try {
                                  await ref.read(authControllerProvider.notifier).signOut();
                                  if (context.mounted) {
                                    context.go('/login');
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error signing out: $e")),
                                  );
                                }
                              },
                              iconColor: Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading profile",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(recruiterProfileProvider(user.uid)),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  "Authentication Error",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text("Go to Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to safely get profile image
  ImageProvider? _getProfileImage(String? authPhotoURL, String? profilePhotoURL) {
    if (authPhotoURL != null) {
      return NetworkImage(authPhotoURL);
    } else if (profilePhotoURL != null) {
      return NetworkImage(profilePhotoURL);
    }
    // Return null instead of AssetImage to let the CircleAvatar show the icon fallback
    return null;
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Password',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ref.read(authControllerProvider.notifier).updatePassword(
                    passwordController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating password: $e')),
                    );
                    Navigator.pop(context);
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3A4B),
            ),
            child: Text(
              'Update',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: iconColor ?? const Color(0xFF2C3A4B),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
