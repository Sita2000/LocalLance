import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/job_controller.dart';
import '../../db/models/job_model.dart';
import '../../auth_screen/controllers/auth_controller.dart'; // Added import for authStateProvider

class JobDetailsScreen extends ConsumerStatefulWidget {
  static const String routePath = '/freelancer/jobs';
  static const String routeName = 'freelancer_jobs';
  
  final bool isRecruiter;
  final String? contactNumber;
  final String? jobId; // Add jobId parameter
  
  const JobDetailsScreen({
    super.key, 
    required this.isRecruiter,
    this.contactNumber,
    this.jobId
  });

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    try {
      if (!await launchUrl(launchUri)) {
        throw Exception('Could not launch $launchUri');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch job details when screen loads if we have a jobId
    if (widget.jobId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(jobNotifierProvider.notifier).getJob(widget.jobId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // App's primary dark blue color
    final Color primaryColor = const Color(0xFF1E3A5F);
    
    // Get job details from provider if we have a jobId
    final jobState = ref.watch(jobNotifierProvider);
    
    // Show loading indicator if job is being fetched
    if (widget.jobId != null && jobState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Job Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Handle errors
    if (widget.jobId != null && jobState.hasError) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Job Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading job details', style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: () {
                  ref.read(jobNotifierProvider.notifier).getJob(widget.jobId!);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Get contact number from either the job or the passed parameter
    String? contactNumber = widget.contactNumber;
    Job? job = jobState.value;
    
    if (job != null) {
      contactNumber = job.contactNo;
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Job Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Only show bookmark icon for freelancer view
          if (!widget.isRecruiter)
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              onPressed: () {},
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job icon and title section
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  // Job icon
                  Center(
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(job?.category ?? ''),
                        color: primaryColor,
                        size: 30.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  
                  // Job title and subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Text(
                      job?.title ?? 'Job Title',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    job?.category ?? 'Category',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  
                  // Status chips row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Price chip
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 16.sp,
                                color: Colors.amber[800],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '₹${job != null ? job.price.toString() : '0'}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        
                        // Status chip
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(job?.status ?? 'open').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: _getStatusColor(job?.status ?? 'open').withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(job?.status ?? 'open'),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                _formatStatus(job?.status ?? 'open'),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(job?.status ?? 'open'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 10.h),
            
            // Description section
            _buildSection(
              title: 'Description',
              content: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Text(
                  job?.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 10.h),
            
            // Posted By section
            _buildSection(
              title: 'Posted By',
              content: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        job?.recruiterName ?? 'Recruiter',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    // Only show call button for freelancers, not for recruiters
                    if (!widget.isRecruiter && contactNumber != null)
                      ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(contactNumber!),
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: Text(
                          'Call',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.w, 
                            vertical: 8.h
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 10.h),
            
            // Date section
            if (job != null)
              _buildSection(
                title: 'Job Date',
                content: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(job.date),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              
            SizedBox(height: 10.h),
            
            // Skills Required section - We'll show category info as skills
            _buildSection(
              title: 'Skills Required',
              content: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getSkillsForCategory(job?.category ?? '').map((skill) => 
                    _buildSkillItem(skill)
                  ).toList(),
                ),
              ),
            ),
            
            SizedBox(height: 10.h),
            
            // Location section
            _buildSection(
              title: 'Job Location',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Text(
                      job?.location ?? 'No location specified',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  
                  // Map container - For a full implementation, you would integrate with Google Maps here
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.w),
                    height: 150.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Stack(
                        children: [
                          // This would be replaced with an actual Google Map widget
                          Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.map,
                                size: 50.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          
                          // Location info overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              color: Colors.white.withOpacity(0.9),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Location',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          job?.location ?? 'Not specified',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              if (job != null && !widget.isRecruiter) {
                // Apply for the job
                ref.read(jobNotifierProvider.notifier).applyForJob(job.id, ref.read(authStateProvider).value?.uid ?? '');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application submitted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to build section containers
  Widget _buildSection({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          content,
        ],
      ),
    );
  }
  
  // Helper method to build skill item with bullet point
  Widget _buildSkillItem(String skill) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Expanded(
            child: Text(
              skill,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get an icon for a category
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
        return Icons.delivery_dining;
      case 'computer repair':
        return Icons.computer;
      case 'web development':
        return Icons.web;
      default:
        return Icons.work;
    }
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
  
  // Helper to get skills based on job category
  List<String> _getSkillsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return [
          'Knowledge of cleaning products and techniques',
          'Attention to detail and thoroughness',
          'Physical stamina for extended cleaning tasks',
          'Time management for efficient cleaning'
        ];
      case 'gardening':
        return [
          'Plant care and maintenance knowledge',
          'Understanding of seasonal gardening requirements',
          'Lawn care and landscaping skills',
          'Knowledge of gardening tools and equipment'
        ];
      case 'plumbing':
        return [
          'Pipe fitting and repair expertise',
          'Fixture installation knowledge',
          'Drain cleaning and maintenance skills',
          'Problem diagnosis abilities'
        ];
      case 'electrical':
        return [
          'Electrical wiring and repair knowledge',
          'Safety protocols awareness',
          'Fixture installation skills',
          'Troubleshooting electrical problems'
        ];
      case 'carpentry':
        return [
          'Woodworking and joinery skills',
          'Measurement and precision abilities',
          'Knowledge of carpentry tools',
          'Furniture repair and construction expertise'
        ];
      case 'painting':
        return [
          'Surface preparation techniques',
          'Knowledge of paint types and finishes',
          'Precision and attention to detail',
          'Color matching abilities'
        ];
      case 'moving':
        return [
          'Physical strength for lifting heavy items',
          'Careful handling of fragile possessions',
          'Efficient packing and unpacking skills',
          'Space management abilities'
        ];
      case 'delivery':
        return [
          'Time management for on-time deliveries',
          'Route planning and navigation skills',
          'Safe handling of packages',
          'Customer service abilities'
        ];
      case 'computer repair':
        return [
          'Hardware troubleshooting expertise',
          'Software diagnostics and repair',
          'Computer component knowledge',
          'Problem-solving abilities'
        ];
      case 'web development':
        return [
          'HTML, CSS, and JavaScript proficiency',
          'Responsive design implementation',
          'Framework experience (React, Angular, or Vue)',
          'Backend integration knowledge'
        ];
      default:
        return [
          'Good communication skills',
          'Punctuality and reliability',
          'Problem-solving abilities',
          'Attention to detail'
        ];
    }
  }
}