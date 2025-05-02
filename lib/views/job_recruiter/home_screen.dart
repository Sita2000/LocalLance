import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mylocallance/views/job_recruiter/job_details_screen.dart';
import 'package:mylocallance/views/job_recruiter/job_post_screen.dart';
import 'package:mylocallance/views/job_recruiter/myjob_screen.dart';
import 'package:mylocallance/views/job_recruiter/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_screen/controllers/auth_controller.dart';
import '../../controllers/job_controller.dart';
import '../../db/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RecruiterHomePage extends ConsumerStatefulWidget {
  static const String routePath = "/recruiter_home";
  static const String routeName = "Recruiter Home";
  const RecruiterHomePage({super.key});

  @override
  ConsumerState<RecruiterHomePage> createState() => _RecruiterHomePageState();
}

class _RecruiterHomePageState extends ConsumerState<RecruiterHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _searchQuery;
  bool _isLoading = false;
  int _selectedIndex = 0; // Track selected navigation item
  
  void _showJobRecruiterDrawer(BuildContext context) {
    // Get current user
    final authState = ref.watch(authStateProvider);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: _buildDrawerContent(context, authState),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  Widget _buildDrawerContent(BuildContext context, AsyncValue<dynamic> authState) {
    return authState.when(
      data: (user) {
        if (user == null) {
          return _buildSignInNeeded(context);
        }
        
        // User is logged in, show profile drawer
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile section
                  Center(
                    child: Column(
                      children: [
                        // Profile image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E3A5F),
                            image: user.photoURL != null 
                              ? DecorationImage(
                                  image: NetworkImage(user.photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          ),
                          child: user.photoURL == null 
                            ? Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              )
                            : null,
                        ),
                        SizedBox(height: 10),
                        // Name
                        Text(
                          user.displayName ?? 'Job Recruiter',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Email
                        Text(
                          user.email ?? 'No email',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Edit profile button
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close drawer
                            context.pushNamed(RecruiterProfileScreen.routeName);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A5F),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
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
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildDrawerItem(Icons.person_outline, 'Profile Overview', 
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.pushNamed(RecruiterProfileScreen.routeName);
                    }
                  ),
                  _buildDrawerItem(Icons.work_outline, 'Post Jobs', 
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.push(JobPostScreen.routePath);
                    }
                  ),
                  _buildDrawerItem(Icons.business_center_outlined, 'My Jobs', 
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.pushNamed(MyJobScreen.routeName);
                    }
                  ),
                  _buildDrawerItem(Icons.description_outlined, 'Proposals/Applications'),
                  _buildDrawerItem(Icons.message_outlined, 'Message'),
                  _buildDrawerItem(Icons.people_outline, 'Hired Freelancers'),
                  _buildDrawerItem(Icons.star_outline, 'Review & ratings'),
                  _buildDrawerItem(Icons.payment_outlined, 'Payments'),
                  _buildDrawerItem(Icons.subscriptions_outlined, 'Subscriptions'),
                  _buildDrawerItem(Icons.settings_outlined, 'Settings'),
                  _buildDrawerItem(Icons.help_outline, 'Help & Support'),
                  _buildDrawerItem(Icons.logout, 'Logout', 
                    onTap: () async {
                      try {
                        await ref.read(authControllerProvider.notifier).signOut();
                        if (context.mounted) {
                          Navigator.pop(context); // Close drawer
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out successfully')),
                          );
                          context.go('/login');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error signing out: $e")),
                        );
                      }
                    }
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading profile: ${error.toString()}'),
      ),
    );
  }

  Widget _buildSignInNeeded(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.account_circle, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'Sign in to Access Your Profile',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close drawer
            context.go('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A5F),
          ),
          child: Text(
            'Sign In',
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF1E3A5F),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle bottom navigation tap
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0: // Home
        break; // Already on home screen
      case 1: // Post Job
        context.push(JobPostScreen.routePath);
        break;
      case 2: // Profile
        context.pushNamed(RecruiterProfileScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Section with dark blue background
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A5F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Menu Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      authState.when(
                        data: (user) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null ? "Welcome, ${user.displayName?.split(' ')[0] ?? 'Recruiter'}" : "Let's Get",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Find the Perfect Freelancer for Your Job!",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        loading: () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Loading...",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Please wait",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        error: (e, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Let's Get",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "You Hired For The Job You Deserve!",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showJobRecruiterDrawer(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.isNotEmpty ? value : null;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search for your jobs...",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content Area (Scrollable)
            Expanded(
              child: authState.when(
                data: (user) {
                  if (user == null) {
                    return _buildSignInRequired(context);
                  }
                  
                  // User is signed in, fetch their jobs
                  return _buildJobsContent(context, user.uid);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading user profile',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.work),
      //       label: 'Post Job',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: const Color(0xFF1E3A5F),
      //   onTap: _onItemTapped,
      // ),
    );
  }

  Widget _buildSignInRequired(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Sign in to view your dashboard',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Sign In',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsContent(BuildContext context, String userId) {
    // Get jobs posted by this recruiter
    final myJobsAsync = ref.watch(recruiterJobsProvider(userId));
    // Get all jobs (for recommended jobs)
    final allJobsAsync = ref.watch(allJobsProvider);
    
    return myJobsAsync.when(
      data: (myJobs) {
        int totalJobs = myJobs.length;
        int ongoingJobs = myJobs.where((job) => job.status == 'in-progress').length;
        int completedJobs = myJobs.where((job) => job.status == 'completed').length;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Summary Cards (Horizontal)
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      "$totalJobs",
                      "Total Jobs",
                      const Color(0xFFEEF2F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      "$ongoingJobs",
                      "Ongoing",
                      const Color(0xFFFAEEEE),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      "$completedJobs",
                      "Completed",
                      const Color(0xFFEEF6F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // My Recent Jobs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Recent Jobs",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const MyJobScreen(),
                    )),
                    child: Text(
                      "View All",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // My recent jobs list
              myJobs.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No jobs posted yet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.push(JobPostScreen.routePath),
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Post a Job",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A5F),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myJobs.length > 3 ? 3 : myJobs.length,
                      itemBuilder: (context, index) {
                        final job = myJobs[index];
                        return _buildJobCard(
                          context,
                          job.recruiterName ?? "You",
                          job.title,
                          job.category,
                          job.description,
                          "${DateFormat('MMM dd, yyyy').format(job.date)} | ${job.location.split(',')[0]}",
                          job.status == 'open' ? 'Active' : job.status == 'in-progress' ? 'In Progress' : job.status.substring(0, 1).toUpperCase() + job.status.substring(1),
                          job.price.toInt(),
                          isCompleted: job.status == 'completed',
                          jobId: job.id,
                        );
                      },
                    ),
              
              const SizedBox(height: 32),
              
    
              
              // Recommended jobs
              allJobsAsync.when(
                data: (allJobs) {
                  // Filter jobs that are not by the current user
                  final recommendedJobs = allJobs
                      .where((job) => job.recruiterId != userId)
                      .toList();
                  
                  if (recommendedJobs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Text(
                          'No recommended jobs available',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendedJobs.length > 3 ? 3 : recommendedJobs.length,
                    itemBuilder: (context, index) {
                      final job = recommendedJobs[index];
                      return _buildJobCard(
                        context,
                        job.recruiterName ?? "Unknown",
                        job.title,
                        job.category,
                        job.description,
                        "${DateFormat('MMM dd, yyyy').format(job.date)} | ${job.location.split(',')[0]}",
                        job.status == 'open' ? 'Active' : job.status == 'in-progress' ? 'In Progress' : job.status.substring(0, 1).toUpperCase() + job.status.substring(1),
                        job.price.toInt(),
                        isCompleted: job.status == 'completed',
                        jobId: job.id,
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'Error loading recommended jobs',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading your jobs',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(recruiterJobsProvider(userId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build summary cards
  Widget _buildSummaryCard(String number, String title, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build job cards
  Widget _buildJobCard(
    BuildContext context,
    String postedBy,
    String jobTitle,
    String category,
    String description,
    String dateInfo,
    String status,
    int price, {
    required bool isCompleted,
    required String jobId,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> JobDetailsScreen(jobId: jobId)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Posted by section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Posted by $postedBy",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFEEF6F0)
                          : status == 'In Progress'
                              ? const Color(0xFFFFF8E1)
                              : const Color(0xFFFAEEEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: isCompleted
                            ? Colors.green
                            : status == 'In Progress'
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Job title and icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        jobTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Category
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                description.length > 100 
                    ? '${description.substring(0, 100)}...'
                    : description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Date info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateInfo,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "₹ $price",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to get category icon
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'gardening':
        return Icons.yard;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'carpentry':
        return Icons.handyman;
      case 'painting':
        return Icons.format_paint;
      case 'moving':
        return Icons.local_shipping;
      case 'delivery':
        return Icons.local_shipping;
      case 'computer repair':
        return Icons.computer;
      case 'web development':
        return Icons.web;
      default:
        return Icons.work;
    }
  }
  
  // Helper method to build navigation items
  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    final selectedColor = const Color(0xFF1E3A5F);
    final unselectedColor = Colors.grey[400];
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}