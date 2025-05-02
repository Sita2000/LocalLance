import 'package:go_router/go_router.dart';
import 'package:mylocallance/shared/bottom_nav_page.dart';
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

// Simulated role-checking function. Replace with your real logic.
Future<String?> getUserRole() async {
  return 'freelancer';
  // TODO: Replace with real authentication/role logic
  // Return 'freelancer', 'job_recruiter', or null if not logged in
  return null; // e.g., await AuthService.getCurrentUserRole();
}

final GoRouter appRouter = GoRouter(
  initialLocation: BottomNavPage.routePath,
  redirect: (context, state) async {
    final role = await getUserRole();
    if (role == 'freelancer') {
      return FreelancerBottomNavPage.routePath;
    } else if (role == 'job_recruiter') {
      return '/recruiter/login';
    }
    return null; // stay on current route
  },
  routes: [
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
    GoRoute(
      path: "/recruiter_home",
      builder: (context, state) => RecruiterHomePage(),
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
      path: JobDetailsScreen.routePath,
      name: JobDetailsScreen.routeName,
      builder: (context, state) => const JobDetailsScreen(isRecruiter: false),
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
    // Recruiter routes
    GoRoute(
      path: '/recruiter/login',
      builder: (context, state) => LoginScreenV2(),
    ),
    GoRoute(
      path: '/recruiter/job_details/:jobId',
      name: recruiter.JobDetailsScreen.routeName,
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return recruiter.JobDetailsScreen(jobId: jobId);
      },
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
  ],
);
