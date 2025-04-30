import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../controllers/job_controller.dart';
import '../../auth_screen/controllers/auth_controller.dart';
import '../../db/models/job_model.dart';

class MyJobScreen extends ConsumerWidget {
  static const String routePath = '/myjob_screen';
  static const String routeName = 'My Job';

  const MyJobScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user ID
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Please log in to view your jobs'),
            ),
          );
        }
        
        // Get jobs for this recruiter
        final recruiterJobsAsyncValue = ref.watch(recruiterJobsProvider(user.uid));
        
        return Scaffold(
          backgroundColor: Colors.grey[50],
          // App Bar
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E3A5F),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'My Jobs',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),

          body: recruiterJobsAsyncValue.when(
            data: (jobs) {
              // Count stats
              int totalPosts = jobs.length;
              int activeJobs = jobs.where((job) => job.status == 'open').length;
              int inProgressJobs = jobs.where((job) => job.status == 'in-progress').length;
              int completedJobs = jobs.where((job) => job.status == 'completed').length;
              int pendingJobs = jobs.where((job) => 
                  job.status != 'open' && 
                  job.status != 'in-progress' && 
                  job.status != 'completed').length;
              
              return SafeArea(
                child: Column(
                  children: [
                    // Stats Bar
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Post', totalPosts.toString()),
                          _buildStatDivider(),
                          _buildStatItem('Active', activeJobs.toString()),
                          _buildStatDivider(),
                          _buildStatItem('In Progress', inProgressJobs.toString()),
                          _buildStatDivider(),
                          _buildStatItem('Completed', completedJobs.toString()),
                          _buildStatDivider(),
                          _buildStatItem('Pending', pendingJobs.toString()),
                        ],
                      ),
                    ),

                    // Active Jobs Section
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Jobs',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    // Job List
                    jobs.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  size: 64.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No jobs posted yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/job_post'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A5F),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Post a Job',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: jobs.length,
                            itemBuilder: (context, index) {
                              final job = jobs[index];
                              return _buildJobCard(context, ref, job);
                            },
                          ),
                        ),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('Error loading jobs: ${error.toString()}'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24.h,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildJobCard(BuildContext context, WidgetRef ref, Job job) {
    // Get status color based on job status
    Color statusColor;
    String statusText = job.status;
    
    switch (job.status) {
      case 'open':
        statusColor = Colors.blue;
        statusText = 'Active';
        break;
      case 'in-progress':
        statusColor = Colors.orange;
        statusText = 'In Progress';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
    }
    
    // Format date
    final formattedDate = DateFormat('MMM d, yyyy').format(job.date);
    final daysSincePosted = DateTime.now().difference(job.date).inDays;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Header
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    job.category,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        job.location,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Posted $formattedDate${daysSincePosted > 0 ? ' • Updated ${daysSincePosted == 1 ? "1 day" : "$daysSincePosted days"} ago' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                
                if (job.applicantIds != null && job.applicantIds!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${job.applicantIds!.length} applicant${job.applicantIds!.length != 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Price Section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '₹${job.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to job details using GoRouter with job ID
                    context.pushNamed(
                      'job_details',
                      pathParameters: {'jobId': job.id},
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A5F),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
