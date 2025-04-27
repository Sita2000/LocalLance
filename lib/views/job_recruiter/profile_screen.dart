import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mylocallance/views/job_recruiter/edit_profile_screen.dart';

class RecruiterProfileScreen extends StatelessWidget {
  static const String routePath = "/recruiter_profile";
  static const String routeName = "Recruiter Profile";
  const RecruiterProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double profileImageSize = width * 0.25;
    final double iconSize = width * 0.06;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 480,
            minWidth: 320,
          ),
          margin: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
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
                decoration: BoxDecoration(
                  color: Color(0xFF2C3A4B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.only(
                  left: 8, right: 8, top: 8, bottom: 24,
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 8),
                        CircleAvatar(
                          radius: profileImageSize / 2,
                          backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your asset
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Ishi Roy",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Recruiter",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "recruiter@gmail.com",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified, color: Colors.amber, size: iconSize),
                            SizedBox(width: 4),
                            Text(
                              "19 months",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.star, color: Colors.lightBlueAccent, size: iconSize),
                            SizedBox(width: 4),
                            Text(
                              "28 hires",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.pushNamed(EditProfileScreen.routeName);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF2C3A4B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            textStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            elevation: 2,
                          ),
                          child: Text("Edit Profile"),
                        ),
                      ],
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
                      onTap: () {},
                    ),
                    SizedBox(height: 16),
                    _ActionCard(
                      icon: Icons.lock_rounded,
                      label: "Change password",
                      onTap: () {},
                    ),
                    SizedBox(height: 16),
                    _ActionCard(
                      icon: Icons.logout_rounded,
                      label: "Logout",
                      onTap: () {},
                      iconColor: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? Color(0xFF2C3A4B), size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF23242A),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
