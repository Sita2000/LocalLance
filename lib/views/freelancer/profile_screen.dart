import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/freelancer_provider.dart';
import '../../auth_screen/controllers/auth_controller.dart';
import '../../services/user_preferences_service.dart';

class FreelancerProfileScreen extends ConsumerWidget {
  static const String routePath = '/freelancer/profile';
  static const String routeName = 'freelancer_profile';
  const FreelancerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current user ID
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          // Not logged in
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Please log in to view your profile',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Get freelancer profile data
        final freelancerProfile = ref.watch(freelancerProfileProvider(user.uid));
        final freelancerStats = ref.watch(freelancerStatsProvider(user.uid));
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 32.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Header section with user data
                    _buildHeader(context, ref, user),
                    
                    // Main content with profile data
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          _buildStatsRow(context, freelancerStats),
                          SizedBox(height: 24.h),
                          _buildJobCategorySection(context, freelancerProfile),
                          SizedBox(height: 24.h),
                          _buildProfileDetailsSection(context, freelancerProfile),
                          SizedBox(height: 24.h),
                          _buildLogoutButton(context, ref),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }

  // Header with profile avatar, name, email and edit button
  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic user) {
    final freelancerProfileAsync = ref.watch(freelancerProfileProvider(user.uid));
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Back button and title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Freelancer Profile',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 24.w),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Profile avatar (use Firebase image if available, otherwise default)
          freelancerProfileAsync.when(
            data: (profileData) {
              return Container(
                height: 80.h,
                width: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: (user.photoURL != null || profileData?['photoURL'] != null)
                    ? DecorationImage(
                        image: NetworkImage(user.photoURL ?? profileData?['photoURL']),
                        fit: BoxFit.cover,
                      )
                    : null,
                ),
                child: (user.photoURL == null && (profileData == null || profileData['photoURL'] == null))
                  ? Icon(
                      Icons.person,
                      size: 40.sp,
                      color: Colors.grey[500],
                    )
                  : null,
              );
            },
            loading: () => Container(
              height: 80.h,
              width: 80.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            error: (_, __) => Container(
              height: 80.h,
              width: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Icon(
                Icons.person,
                size: 40.sp,
                color: Colors.grey[500],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          
          // Name
          Text(
            user.displayName ?? 'Freelancer',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          
          // Email
          Text(
            user.email ?? 'No email available',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 12.h),
          
          // Edit profile button
          GestureDetector(
            onTap: () {
              // Navigate to edit profile screen (to be implemented)
              // context.pushNamed('freelancer_edit_profile');
            },
            child: Container(
              height: 32.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Stats row with Total Jobs, Earnings, and Ratings
  Widget _buildStatsRow(BuildContext context, AsyncValue<Map<String, dynamic>> statsAsync) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: statsAsync.when(
        data: (stats) {
          final totalJobs = stats['totalJobs'] as int;
          final earnings = stats['earnings'] as double;
          final rating = stats['rating'] as double;
          
          return Row(
            children: [
              _buildStatCard('$totalJobs', 'Total Jobs'),
              SizedBox(width: 12.w),
              _buildStatCard('₹${earnings.toStringAsFixed(0)}', 'Earnings'),
              SizedBox(width: 12.w),
              _buildStatCard('★ ${rating.toStringAsFixed(1)}', 'Rating'),
            ],
          );
        },
        loading: () => Row(
          children: [
            _buildStatCard('-', 'Total Jobs'),
            SizedBox(width: 12.w),
            _buildStatCard('-', 'Earnings'),
            SizedBox(width: 12.w),
            _buildStatCard('-', 'Rating'),
          ],
        ),
        error: (_, __) => Row(
          children: [
            _buildStatCard('0', 'Total Jobs'),
            SizedBox(width: 12.w),
            _buildStatCard('₹0', 'Earnings'),
            SizedBox(width: 12.w),
            _buildStatCard('★ 0.0', 'Rating'),
          ],
        ),
      ),
    );
  }

  // Individual stat card
  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Job Category section with chips
  Widget _buildJobCategorySection(BuildContext context, AsyncValue<Map<String, dynamic>?> profileAsync) {
    return profileAsync.when(
      data: (profileData) {
        // Get job categories from profile
        final jobCategories = profileData?['jobCategories'] as List<dynamic>? ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Categories',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            
            // Job category chips
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: jobCategories.isEmpty
                ? [
                    _buildCategoryChip('No categories yet'),
                  ]
                : jobCategories.map<Widget>((category) => _buildCategoryChip(category)).toList(),
            ),
            SizedBox(height: 12.h),
            
            // Add category dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Category',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Categories',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Error loading categories',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Individual category chip
  Widget _buildCategoryChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF1E3A5F),
        ),
      ),
    );
  }

  // Profile details section
  Widget _buildProfileDetailsSection(BuildContext context, AsyncValue<Map<String, dynamic>?> profileAsync) {
    return profileAsync.when(
      data: (profileData) {
        // Get relevant profile data
        final skills = profileData?['skills'] as String? ?? 'Not specified';
        final phone = profileData?['phone'] as String? ?? 'Not specified';
        final gender = profileData?['gender'] as String? ?? 'Not specified';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            _buildProfileDetailItem('Skills', skills),
            SizedBox(height: 16.h),
            _buildProfileDetailItem('Phone', phone),
            SizedBox(height: 16.h),
            _buildProfileDetailItem('Gender', gender),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Error loading profile details',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Individual profile detail item
  Widget _buildProfileDetailItem(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Value
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: label == 'Resume' 
                    ? const Color(0xFF1E3A5F)
                    : Colors.grey[800],
                decoration: label == 'Resume'
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Edit icon
          Icon(
            Icons.edit,
            size: 16.sp,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
  
  // Logout button
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            // Clear user role from SharedPreferences
            final prefsService = UserPreferencesService();
            await prefsService.clearUserData();
            
            // Sign out
            await ref.read(authControllerProvider.notifier).signOut();
            
            // Navigate to login screen
            if (context.mounted) {
              context.go('/login');
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error signing out: $e')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}