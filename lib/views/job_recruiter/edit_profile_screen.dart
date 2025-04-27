import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mylocallance/shared/bottom_nav_page.dart';
import 'package:mylocallance/views/job_recruiter/profile_screen.dart';

class EditProfileScreen extends StatelessWidget {
  static const routeName = 'Edit Profile';
  static const routePath = '/edit-profile';
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final profileImageSize = width * 0.25;
    final fieldFontSize = width < 360 ? 14.0 : 16.0;
    final buttonWidth = width * 0.85;
    final verticalGap = width < 360 ? 14.0 : 18.0;
    final borderRadius = BorderRadius.circular(24);
    final fieldRadius = BorderRadius.circular(14);
    final fieldBg = const Color(0xFFF3F6FA);
    final darkBlue = const Color(0xFF1E3A5F);
    final subtitleColor = Colors.grey[500];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1FA), // Light blueish-white
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480, minWidth: 320),
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 24),
                          onPressed: () => context.pop(),
                          splashRadius: 24,
                        ),
                        const Spacer(),
                      ],
                    ),
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: darkBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep your personal details private. Information you add here is visible to anyone who can view your profile.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: subtitleColor,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: verticalGap + 2),
                    // Profile Image
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: profileImageSize / 2,
                            backgroundImage: const AssetImage('assets/profile.jpg'), // Replace with your asset
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Change your profile',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: darkBlue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: verticalGap + 2),
                    // Form Fields
                    _ProfileField(
                      label: 'Username',
                      initialValue: 'Ishi Roy',
                      icon: Icons.person_outline,
                      fontSize: fieldFontSize,
                      fieldBg: fieldBg,
                      fieldRadius: fieldRadius,
                    ),
                    SizedBox(height: verticalGap),
                    _ProfileField(
                      label: 'Email',
                      initialValue: 'recruiter@gmail.com',
                      icon: Icons.email_outlined,
                      fontSize: fieldFontSize,
                      fieldBg: fieldBg,
                      fieldRadius: fieldRadius,
                    ),
                    SizedBox(height: verticalGap),
                    _ProfileField(
                      label: 'Location',
                      initialValue: 'Patna',
                      icon: Icons.location_on_outlined,
                      fontSize: fieldFontSize,
                      fieldBg: fieldBg,
                      fieldRadius: fieldRadius,
                    ),
                    SizedBox(height: verticalGap + 6),
                    // Save Button
                    SizedBox(
                      width: buttonWidth,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          textStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                    SizedBox(height: verticalGap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String initialValue;
  final IconData icon;
  final double fontSize;
  final Color fieldBg;
  final BorderRadius fieldRadius;

  const _ProfileField({
    required this.label,
    required this.initialValue,
    required this.icon,
    required this.fontSize,
    required this.fieldBg,
    required this.fieldRadius,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: fontSize - 2,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: fieldRadius,
          ),
          child: TextFormField(
            initialValue: initialValue,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              suffixIcon: Icon(icon, color: Colors.grey[500]),
            ),
          ),
        ),
      ],
    );
  }
}
