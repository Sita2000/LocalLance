import 'package:go_router/go_router.dart';
import 'package:mylocallance/shared/bottom_nav_page.dart';
import 'package:mylocallance/views/freelancer/chatlist_screen.dart';
import 'package:mylocallance/views/freelancer/chatroom.dart';
import 'package:mylocallance/views/freelancer/dashboard.dart';
import 'package:mylocallance/views/freelancer/job_details_screen.dart';
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

// Simulated role-checking function. Replace with your real logic.
Future<String?> getUserRole() async {
  // TODO: Replace with real authentication/role logic
  // Return 'freelancer', 'job_recruiter', or null if not logged in
  return null; // e.g., await AuthService.getCurrentUserRole();
}

final GoRouter appRouter = GoRouter(
  initialLocation: BottomNavPage.routePath,
  redirect: (context, state) async {
    final role = await getUserRole();
    if (role == 'freelancer') {
      return '/freelancer/dashboard';
    } else if (role == 'job_recruiter') {
      return '/recruiter/login';
    }
    return null; // stay on current route
  },
  routes: [
    GoRoute(
      path: BottomNavPage.routePath,
      name: BottomNavPage.routeName,
      builder: (context, state) => BottomNavPage(),
    ),
    GoRoute(
      path: "/recruiter_home",
      builder: (context, state) => RecruiterHomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreenV2(),
    ),
    GoRoute(
      path: '/freelancer/dashboard',
      builder: (context, state) => FreelancerDashboard(),
      routes: [
        GoRoute(
          path: 'chatlist',
          builder: (context, state) => ChatScreen(),
        ),
        GoRoute(
          path: 'chatroom',
          builder: (context, state) => ChatroomScreen(),
        ),
        GoRoute(
          path: 'job_details',
          builder: (context, state) => JobDetailsScreen(isRecruiter: false),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => NotificationsScreen(),
        ),
        GoRoute(
          path: 'payment',
          builder: (context, state) => PaymentScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => ProfileScreen(),
        ),
        GoRoute(
          path: 'review',
          builder: (context, state) => ReviewScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/recruiter/login',
      builder: (context, state) => LoginScreenV2(),
    ),
    GoRoute(
      path: '/recruiter/job_details',
      builder: (context, state) => JobDetailsScreen(isRecruiter: true),
    ),
    GoRoute(
      path: '/job_post',
      builder: (context, state) => const JobPostScreen(),
    ),
    GoRoute(
      path: '/myjob_screen',
      name: MyJobScreen.routeName,
      builder: (context, state) => MyJobScreen(),
    ),
    GoRoute(
      path: '/recruiter_profile',
      builder: (context, state) => RecruiterProfileScreen(),
    ),
    GoRoute(
      path: EditProfileScreen.routePath,
      name: EditProfileScreen.routeName,
      builder: (context, state) => EditProfileScreen(),
    ),
     
    // Add more recruiter routes here as needed
  ],
);
