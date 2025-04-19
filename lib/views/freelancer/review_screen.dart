import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  // Sample data for reviews
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Ishil Roy',
      'position': 'Marketing Manager',
      'review': 'Excellent work! Delivered on time and exceeded expectations.',
      'rating': 5,
      'date': 'Apr 04, 2025',
    },
    {
      'name': 'Ishil Roy',
      'position': 'Marketing Manager',
      'review': 'Excellent work! Delivered on time and exceeded expectations.',
      'rating': 5,
      'date': 'Apr 04, 2025',
    },
    {
      'name': 'Ishil Roy',
      'position': 'Marketing Manager',
      'review': 'Excellent work! Delivered on time and exceeded expectations.',
      'rating': 5,
      'date': 'Apr 04, 2025',
    },
    {
      'name': 'Ishil Roy',
      'position': 'Marketing Manager',
      'review': 'Excellent work! Delivered on time and exceeded expectations.',
      'rating': 5,
      'date': 'Apr 04, 2025',
    },
    {
      'name': 'Ishil Roy',
      'position': 'Marketing Manager',
      'review': 'Excellent work! Delivered on time and exceeded expectations.',
      'rating': 5,
      'date': 'Apr 04, 2025',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Review',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              'Reviewed by Recruiters',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final delayedAnimation = CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        delay < 0.9 ? delay : 0.9,
                        1.0,
                        curve: Curves.easeOut,
                      ),
                    );
                    return FadeTransition(
                      opacity: delayedAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(delayedAnimation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildReviewCard(_reviews[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile avatar
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    review['name'].substring(0, 2),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Name and position
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['name'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        review['position'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Message icon
                InkWell(
                  onTap: () {
                    debugPrint('Message tapped');
                    // Navigate to chat screen if needed
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.message,
                      color: Colors.blue,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Review content
            Text(
              review['review'],
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            // Rating and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Star rating
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18.sp,
                    );
                  }),
                ),
                // Date
                Text(
                  review['date'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}