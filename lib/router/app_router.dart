import 'package:go_router/go_router.dart';
import 'package:mylocallance/views/freelancer/chatlist_screen.dart';
import 'package:mylocallance/views/freelancer/chatroom.dart';
import 'package:mylocallance/views/freelancer/dashboard.dart';
import 'package:mylocallance/views/freelancer/job_details_screen.dart';
import 'package:mylocallance/views/freelancer/notifications.dart';
import 'package:mylocallance/views/freelancer/payment_screen.dart';
import 'package:mylocallance/views/freelancer/profile_screen.dart';
import 'package:mylocallance/views/freelancer/review_screen.dart';
import 'package:mylocallance/views/auth/login_screen.dart';

// Simulated role-checking function. Replace with your real logic.
Future<String?> getUserRole() async {
  // TODO: Replace with real authentication/role logic
  // Return 'freelancer', 'job_recruiter', or null if not logged in
  return null; // e.g., await AuthService.getCurrentUserRole();
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
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
          builder: (context, state) => JobDetailsScreen(),
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
    // Add more recruiter routes here as needed
  ],
);
