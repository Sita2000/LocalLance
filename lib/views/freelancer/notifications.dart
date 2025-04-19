import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                // App Bar with back button and title
                _buildHeader(),
                
                // Main content - Notifications list
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Column(
                        children: [
                          _buildNotificationCard(),
                          SizedBox(height: 12.h),
                          _buildNotificationCard(),
                          SizedBox(height: 12.h),
                          _buildNotificationCard(),
                          SizedBox(height: 12.h),
                          _buildNotificationCard(),
                          SizedBox(height: 12.h),
                          _buildNotificationCard(),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom navigation bar
                _buildBottomNavigationBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header with back button and title
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                size: 18.sp,
                color: Colors.black,
              ),
            ),
          ),
          
          // Centered title
          Expanded(
            child: Center(
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Empty space to balance the back button
          SizedBox(width: 36.w),
        ],
      ),
    );
  }

  // Individual notification card
  Widget _buildNotificationCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Main notification content
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue avatar
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(width: 12.w),
                
                // Notification text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification title and timestamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "You're invited to apply!",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "15h",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      
                      // Notification description
                      Text(
                        "Perfect! Again static 'Share as learn to do more. Discard the invites quickly, to make space answer before the slot closes. Perfect! Again static 'Share as learn to do more...",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Three dots menu
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Icon(
                    Icons.more_vert,
                    size: 20.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Job details card
          Container(
            margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            padding: EdgeInsets.all(12.r),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Job Title As Dog walking",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.bookmark_border,
                      size: 20.sp,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                
                // Job details
                Row(
                  children: [
                    _buildJobDetail("Recruiter Name:", "SHM"),
                    SizedBox(width: 12.w),
                    _buildJobDetail("Working Location:", "Patna"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Job detail item (label and value)
  Widget _buildJobDetail(String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', false),
          _buildNavItem(Icons.notifications, 'Notifications', true),
          _buildNavItem(Icons.person, 'Profile', false),
        ],
      ),
    );
  }

  // Individual bottom navigation item
  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24.sp,
          color: isActive ? const Color(0xFF1E3A5F) : Colors.grey,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isActive ? const Color(0xFF1E3A5F) : Colors.grey,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}