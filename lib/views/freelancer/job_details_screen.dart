import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // App's primary dark blue color
    final Color primaryColor = const Color(0xFF1E3A5F);
    
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
                        Icons.pets,
                        color: primaryColor,
                        size: 30.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  
                  // Job title and subtitle
                  Text(
                    'Walking Dog in the Park',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Animal Care & Service Jobs',
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
                                '\$5000',
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
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[800],
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
                  'We are looking for someone to provide dog walking services in the local park. The job involves taking care of a medium-sized golden retriever for regular exercise. You will be responsible for ensuring the dog gets proper exercise, stays hydrated, and interacts safely with other dogs. Experience with animals is preferred.',
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
                child: Text(
                  'Miss Ishii',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 10.h),
            
            // Skills Required section
            _buildSection(
              title: 'Skills Required',
              content: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkillItem('Animal handling: Basic understanding of dog behavior and care'),
                    _buildSkillItem('Communication: Clear communication with pet owners'),
                    _buildSkillItem('Responsibility: Ensuring pet safety at all times'),
                    _buildSkillItem('Time management: Punctuality and adherence to schedule'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 10.h),
            
            // Location section
            _buildSection(
              title: 'What\'s your location?',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Text(
                      'Let\'s get your location so we can find your location',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  
                  // Map container
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
                                          'Current Location',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '556 E 37th st, Bailey Road, Patna, 5km',
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
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
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
            onPressed: () {},
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
}