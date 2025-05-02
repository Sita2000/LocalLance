import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mylocallance/services/user_preferences_service.dart';
import 'package:mylocallance/shared/bottom_nav_page.dart';
import 'package:mylocallance/views/freelancer/freelancer_bottom_nav_page.dart';
import 'package:mylocallance/views/job_recruiter/recruiter_bottom_nav_page.dart';

class SplashScreen extends StatefulWidget {
  static const String routePath = '/splash';
  static const String routeName = 'splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Fade Animation (0 to 1 opacity)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Scale Animation (small to normal size)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward(); // Start animation

    // Check authentication status and navigate accordingly after animation completes
    Future.delayed(const Duration(seconds: 2), () async {
      final prefsService = UserPreferencesService();
      final isAuthenticated = await prefsService.isAuthenticated();
      
      if (!isAuthenticated) {
        _navigateToLogin();
        return;
      }
      
      final userRole = await prefsService.getUserRole();
      
      if (!mounted) return; // Check if widget is still mounted before navigating
      
      if (userRole == UserPreferencesService.roleFreelancer) {
        context.go(FreelancerBottomNavPage.routePath);
      } else if (userRole == UserPreferencesService.roleRecruiter) {
        context.go(BottomNavPage.routePath);
      } else {
        // If role is not set or is invalid, go to login
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildLogo(),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/Locallance logo.png',
      width: 150.w,
      height: 150.h,
      fit: BoxFit.contain,
    );
  }
}