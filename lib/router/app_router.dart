import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mylocallance/shared/bottom_nav_page.dart';
import 'package:mylocallance/views/auth/splash_screen.dart';
import 'package:mylocallance/views/freelancer/chatlist_screen.dart';
import 'package:mylocallance/views/freelancer/chatroom.dart';
import 'package:mylocallance/views/freelancer/dashboard.dart';
import 'package:mylocallance/views/freelancer/freelancer_bottom_nav_page.dart';
import 'package:mylocallance/views/freelancer/job_details_screen.dart';
import 'package:mylocallance/views/freelancer/my_job_screen.dart';
import 'package:mylocallance/views/freelancer/notifications.dart';
import 'package:mylocallance/views/freelancer/payment_screen.dart';
import 'package:mylocallance/views/freelancer/profile_screen.dart';
import 'package:mylocallance/views/freelancer/review_screen.dart';
import 'package:mylocallance/views/auth/login_screen.dart';
import 'package:mylocallance/views/job_recruiter/edit_profile_screen.dart';
import 'package:mylocallance/views/job_recruiter/job_post_screen.dart';
import 'package:mylocallance/views/job_recruiter/home_screen.dart';
import 'package:mylocallance/views/job_recruiter/myjob_screen.dart';
import 'package:mylocallance/views/job_recruiter/profile_screen.dart';
import 'package:mylocallance/views/job_recruiter/job_details_screen.dart' as recruiter;
import 'package:mylocallance/views/job_recruiter/recruiter_bottom_nav_page.dart';
import 'package:mylocallance/providers/recruiter_bottom_nav_provider.dart';
import '../services/user_preferences_service.dart';

// Get user role using the UserPreferencesService
Future<String?> getUserRole() async {
  final prefsService = UserPreferencesService();
  return await prefsService.getUserRole();
}

// Check if user is authenticated
Future<bool> isUserAuthenticated() async {
  final prefsService = UserPreferencesService();
  return await prefsService.isAuthenticated();
}

final appRouter = GoRouter(
  initialLocation: '/splash', // Set splash screen as initial route
  redirect: (context, state) async {
    // Allow access to splash screen without redirection
    if (state.matchedLocation == '/splash') {
      return null;
    }
    
    final isAuthenticated = await isUserAuthenticated();
    final role = await getUserRole();
    
    // If user is not authenticated and not on login page, redirect to login
    if (!isAuthenticated) {
      if (state.matchedLocation != '/login') {
        return '/login';
      }
      return null;
    }
    
    // If user is authenticated but trying to access login or splash, redirect based on role
    if (state.matchedLocation == '/login' || state.matchedLocation == '/splash') {
      if (role == UserPreferencesService.roleFreelancer) {
        return FreelancerBottomNavPage.routePath;
      } else if (role == UserPreferencesService.roleRecruiter) {
        return BottomNavPage.routePath;
      }
    }
    
    // If the user is a freelancer, redirect to freelancer dashboard
    if (role == UserPreferencesService.roleFreelancer) {
      if (!state.matchedLocation.startsWith('/freelancer')) {
        return FreelancerBottomNavPage.routePath;
      }
      return null;
    } 
    // If the user is a recruiter, redirect to recruiter home
    else if (role == UserPreferencesService.roleRecruiter) {
      if (!state.matchedLocation.startsWith('/recruiter_')) {
        return BottomNavPage.routePath;
      }
      return null;
    }
    
    return null; // stay on current route
  },
  routes: [
    GoRoute(
      path: SplashScreen.routePath,
      name: SplashScreen.routeName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: FreelancerBottomNavPage.routePath,
      name: FreelancerBottomNavPage.routeName,
      builder: (context, state) => const FreelancerBottomNavPage(),
    ),
    GoRoute(
      path: BottomNavPage.routePath,
      name: BottomNavPage.routeName,
      builder: (context, state) => BottomNavPage(),
    ),
    // Recruiter bottom navigation route
    ShellRoute(
      builder: (context, state, child) {
        return RecruiterBottomNavPage(child: child);
      },
      routes: [
        // Main recruiter routes inside the shell
        GoRoute(
          path: RecruiterBottomNavPage.routePath,
          name: RecruiterBottomNavPage.routeName,
          builder: (context, state) => const RecruiterHomePage(),
        ),
        GoRoute(
          path: '/job_post',
          builder: (context, state) {
            // Update the nav provider to reflect the correct tab
            final container = ProviderScope.containerOf(context);
            container.read(recruiterBottomNavProvider.notifier).setSelectedItem(RecruiterBottomNavItem.postJob);
            return const JobPostScreen();
          },
        ),
        GoRoute(
          path: '/recruiter_profile',
          name: RecruiterProfileScreen.routeName,
          builder: (context, state) {
            // Update the nav provider to reflect the correct tab
            final container = ProviderScope.containerOf(context);
            container.read(recruiterBottomNavProvider.notifier).setSelectedItem(RecruiterBottomNavItem.profile);
            return const RecruiterProfileScreen();
          },
        ),
        GoRoute(
          path: '/myjob_screen',
          name: MyJobScreen.routeName,
          builder: (context, state) => MyJobScreen(),
        ),
        GoRoute(
          path: EditProfileScreen.routePath,
          name: EditProfileScreen.routeName,
          builder: (context, state) => EditProfileScreen(),
        ),
        GoRoute(
          path: '/recruiter/job_details/:jobId',
          name: recruiter.JobDetailsScreen.routeName,
          builder: (context, state) {
            final jobId = state.pathParameters['jobId']!;
            return recruiter.JobDetailsScreen(jobId: jobId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreenV2(),
    ),
    // Freelancer routes
    GoRoute(
      path: FreelancerDashboard.routePath,
      name: FreelancerDashboard.routeName,
      builder: (context, state) => const FreelancerDashboard(),
    ),
    GoRoute(
      path: JobDetailsScreen.routePath + '/:jobId',
      name: JobDetailsScreen.routeName,
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'];
        return JobDetailsScreen(
          isRecruiter: false,
          jobId: jobId,
        );
      },
    ),
    GoRoute(
      path: ChatScreen.routePath,
      name: ChatScreen.routeName,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: FreelancerProfileScreen.routePath,
      name: FreelancerProfileScreen.routeName,
      builder: (context, state) => const FreelancerProfileScreen(),
    ),
    GoRoute(
      path: ChatroomScreen.routePath,
      name: ChatroomScreen.routeName,
      builder: (context, state) => const ChatroomScreen(),
    ),
    GoRoute(
      path: NotificationsScreen.routePath,
      name: NotificationsScreen.routeName,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: PaymentScreen.routePath,
      name: PaymentScreen.routeName,
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: ReviewScreen.routePath,
      name: ReviewScreen.routeName,
      builder: (context, state) => const ReviewScreen(),
    ),
    GoRoute(
      path: FreelancerMyJobScreen.routePath,
      name: FreelancerMyJobScreen.routeName,
      builder: (context, state) => const FreelancerMyJobScreen(),
    ),
    // Recruiter additional routes
    GoRoute(
      path: '/recruiter/login',
      builder: (context, state) => LoginScreenV2(),
    ),
  ],
);
