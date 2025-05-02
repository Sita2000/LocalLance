import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mylocallance/views/freelancer/chatlist_screen.dart';
import 'package:mylocallance/views/freelancer/job_details_screen.dart';
import 'package:mylocallance/views/freelancer/my_job_screen.dart';
import 'package:mylocallance/views/freelancer/payment_screen.dart';
import 'package:mylocallance/views/freelancer/profile_screen.dart';
import 'package:mylocallance/views/freelancer/review_screen.dart';
import 'package:mylocallance/providers/freelancer_bottom_nav_provider.dart';
import '../../controllers/job_controller.dart';
import '../../db/models/job_model.dart';
import '../../auth_screen/controllers/auth_controller.dart';
import '../../providers/freelancer_provider.dart';
import '../../services/user_preferences_service.dart';

class FreelancerDashboard extends ConsumerStatefulWidget {
  static const routePath = '/freelancer/dashboard';
  static const routeName = 'freelancer_dashboard';
  const FreelancerDashboard({super.key});

  @override
  ConsumerState<FreelancerDashboard> createState() => _FreelancerDashboardState();
}

class _FreelancerDashboardState extends ConsumerState<FreelancerDashboard> {
  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['All', 'Applied', 'Recommended'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final selectedItem = ref.watch(freelancerBottomNavProvider);
    final authState = ref.watch(authStateProvider);
    final allJobs = ref.watch(allJobsProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Redirect to login if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Get freelancer profile data for the drawer
        final freelancerProfile = ref.watch(freelancerProfileProvider(user.uid));
        final freelancerStats = ref.watch(freelancerStatsProvider(user.uid));
        
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          drawer: _buildDrawer(context, user, freelancerProfile),
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
            child: Column(
              children: [
                // Top section with app bar and search
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.refresh(allJobsProvider);
                      ref.refresh(freelancerStatsProvider(user.uid));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAppBar(),
                          _buildSearchBar(),
                          _buildJobSummaryCards(user.uid),
                          _buildQuickAccessGrid(context),
                          _buildRecentJobsSection(allJobs),
                          _buildJobFilterTabs(),
                          _buildJobList(user.uid, allJobs),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  // Build the drawer widget with real user data
  Widget _buildDrawer(BuildContext context, dynamic user, AsyncValue<Map<String, dynamic>?> profileAsync) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // User profile section
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // User avatar
                  profileAsync.when(
                    data: (profileData) {
                      return CircleAvatar(
                        radius: 35.r,
                        backgroundColor: const Color(0xFF1E3A5F),
                        backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL) : null,
                        child: user.photoURL == null
                            ? Icon(Icons.person, color: Colors.white, size: 40.r)
                            : null,
                      );
                    },
                    loading: () => CircleAvatar(
                      radius: 35.r,
                      backgroundColor: const Color(0xFF1E3A5F),
                      child: const CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (_, __) => CircleAvatar(
                      radius: 35.r,
                      backgroundColor: const Color(0xFF1E3A5F),
                      child: Icon(Icons.person, color: Colors.white, size: 40.r),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Freelancer',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          user.email ?? 'No email',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 30.h,
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushNamed(FreelancerProfileScreen.routeName);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A5F),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            child: Text(
                              'View Profile',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Menu items with navigation
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                children: [
                  _buildDrawerItem('My Jobs', () {
                    context.pushNamed(FreelancerMyJobScreen.routeName);
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Saved Jobs', () {
                    debugPrint('Saved Jobs tapped');
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Messages', () {
                    context.pushNamed(ChatScreen.routeName);
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Review & Ratings', () {
                    context.pushNamed(ReviewScreen.routeName);
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Payments', () {
                    context.pushNamed(PaymentScreen.routeName);
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Settings', () {
                    debugPrint('Settings tapped');
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Help & Support', () {
                    debugPrint('Help & Support tapped');
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Logout', () async {
                    try {
                      final prefsService = UserPreferencesService();
                      await prefsService.clearUserData();
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error signing out: $e')),
                        );
                      }
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Individual drawer menu item
  Widget _buildDrawerItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Square icon
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 16.w),
            // Item title
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // App Bar with menu icon and notification
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu icon - now opens the drawer
          InkWell(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.menu, size: 24.sp),
            ),
          ),
          
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Notification icon with badge
          Stack(
            children: [
              InkWell(
                onTap: () => context.pushNamed('freelancer_notifications'),
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(Icons.notifications_outlined, size: 24.sp),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10.w,
                  height: 10.h,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Greeting section with user name and subtitle
  Widget _buildGreeting() {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        final firstName = user?.displayName?.split(' ').first ?? 'Freelancer';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi $firstName!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Your Jobs are waiting for you!',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Please wait',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi there!',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Your Jobs are waiting for you!',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          SizedBox(height: 12.h),
          Container(
            height: 45.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for jobs by your skill',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                  size: 20.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Job Summary Cards with stats from Firebase
  Widget _buildJobSummaryCards(String userId) {
    // Fetch freelancer stats
    final freelancerStats = ref.watch(freelancerStatsProvider(userId));
    
    return freelancerStats.when(
      data: (stats) {
        final totalJobs = stats['totalJobs'] as int;
        final completedJobs = stats['completedJobs'] ?? 0;
        final ongoingJobs = totalJobs - completedJobs;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              _buildSummaryCard('Total Jobs', '$totalJobs', Colors.grey[300]!),
              SizedBox(width: 8.w),
              _buildSummaryCard('Ongoing', '$ongoingJobs', Colors.red[100]!),
              SizedBox(width: 8.w),
              _buildSummaryCard('Completed', '$completedJobs', Colors.green[100]!),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            _buildSummaryCard('Total Jobs', '...', Colors.grey[300]!),
            SizedBox(width: 8.w),
            _buildSummaryCard('Ongoing', '...', Colors.red[100]!),
            SizedBox(width: 8.w),
            _buildSummaryCard('Completed', '...', Colors.green[100]!),
          ],
        ),
      ),
      error: (_, __) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            _buildSummaryCard('Total Jobs', '0', Colors.grey[300]!),
            SizedBox(width: 8.w),
            _buildSummaryCard('Ongoing', '0', Colors.red[100]!),
            SizedBox(width: 8.w),
            _buildSummaryCard('Completed', '0', Colors.green[100]!),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color backgroundColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick access grid with navigation
  Widget _buildQuickAccessGrid(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard('New Jobs', Icons.work_outline, () {
                  setState(() {
                    _selectedTabIndex = 0;  // Switch to "All" tab
                  });
                }),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionCard('Applied Jobs', Icons.bookmark_border, () {
                  setState(() {
                    _selectedTabIndex = 1;  // Switch to "Applied" tab
                  });
                }),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildActionCard('Earnings', Icons.attach_money, () {
                  context.pushNamed(PaymentScreen.routeName);
                }),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionCard('Messages', Icons.chat_bubble_outline, () {
                  context.pushNamed(ChatScreen.routeName);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData iconData, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            height: 70.h,
            padding: EdgeInsets.all(8.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    iconData,
                    color: const Color(0xFF1E3A5F),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Recent Jobs Section with real jobs from Firebase
  Widget _buildRecentJobsSection(AsyncValue<List<Job>> jobsAsync) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Jobs',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          
          jobsAsync.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      'No jobs available',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }
              
              // Take only the most recent 5 jobs
              final recentJobs = jobs.take(5).toList();
              
              return SizedBox(
                height: 150.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: recentJobs.length,
                  itemBuilder: (context, index) {
                    final job = recentJobs[index];
                    return _buildJobCard(
                      job.title,
                      '₹${job.price?.toString() ?? "N/A"}',
                      job.date != null ? timeAgo(job.date!) : 'Recent',
                      job.id,
                    );
                  },
                ),
              );
            },
            loading: () => SizedBox(
              height: 150.h,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  'Error loading jobs: $error',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Individual job card in horizontal list
  Widget _buildJobCard(String title, String price, String time, String jobId) {
    return Container(
      width: 140.w, 
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.blue[300],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        child: InkWell(
          onTap: () {
            // Navigate to job details page
            context.pushNamed('job_details', pathParameters: {'jobId': jobId});
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to job details for application
                    context.pushNamed('job_details', pathParameters: {'jobId': jobId});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[700],
                    minimumSize: Size(double.infinity, 28.h),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    textStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Job Filter Tabs
  Widget _buildJobFilterTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(
            _tabTitles.length,
            (index) => _buildFilterTab(index),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index) {
    final bool isSelected = index == _selectedTabIndex;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(4.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
            ),
          ),
          child: Text(
            _tabTitles[index],
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue[700] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // List of jobs based on selected filter tab
  Widget _buildJobList(String userId, AsyncValue<List<Job>> allJobsAsync) {
    return allJobsAsync.when(
      data: (allJobs) {
        // Filter jobs based on the selected tab
        List<Job> filteredJobs;
        
        switch (_selectedTabIndex) {
          case 0: // All jobs
            filteredJobs = allJobs;
            break;
          case 1: // Applied jobs
            filteredJobs = allJobs.where((job) => 
                job.applicantIds != null && 
                job.applicantIds!.contains(userId)).toList();
            break;
          case 2: // Recommended jobs - based on job categories
            // In a real app you'd use a more sophisticated recommendation algorithm
            filteredJobs = allJobs.where((job) => job.status == 'open').toList();
            break;
          default:
            filteredJobs = allJobs;
        }
        
        if (filteredJobs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No jobs found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: filteredJobs.take(5).map((job) => _buildJobListItem(job)).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Text(
            'Error loading jobs: $error',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Individual job item in vertical list
  Widget _buildJobListItem(Job job) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.pushNamed(
              JobDetailsScreen.routeName, 
              pathParameters: {'jobId': job.id}
            );
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: Colors.blue[100],
                            backgroundImage: job.recruiterImageUrl != null
                                ? NetworkImage(job.recruiterImageUrl!)
                                : null,
                            child: job.recruiterImageUrl == null
                                ? Text(
                                    (job.recruiterName?.isNotEmpty == true)
                                        ? job.recruiterName![0].toUpperCase()
                                        : 'R',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            job.recruiterName ?? 'Recruiter',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(job.status ?? 'open').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          _formatStatus(job.status ?? 'open'),
                          style: TextStyle(
                            color: _getStatusColor(job.status ?? 'open'),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    job.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${job.price?.toString() ?? "N/A"}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Updated to navigate with the contactNumber parameter
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => JobDetailsScreen(
                                isRecruiter: false,
                                contactNumber: job.contactNo,
                                jobId: job.id,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper to format job status
  String _formatStatus(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }
  
  // Helper to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'in-progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Helper to format time ago
  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}