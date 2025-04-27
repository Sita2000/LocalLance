import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mylocallance/views/job_recruiter/job_post_screen.dart';
import 'package:mylocallance/views/job_recruiter/myjob_screen.dart';
import 'package:mylocallance/views/job_recruiter/profile_screen.dart';

class RecruiterHomePage extends StatefulWidget {
  static const String routePath = "/recruiter_home";
  static const String routeName = "Recruiter Home";
  const RecruiterHomePage({super.key});

  @override
  State<RecruiterHomePage> createState() => _RecruiterHomePageState();
}

class _RecruiterHomePageState extends State<RecruiterHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  get jobId => null;
  
  void _showJobRecruiterDrawer(BuildContext context) {
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
              child: _buildDrawerContent(context),
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

  Widget _buildDrawerContent(BuildContext context) {
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Name
                    Text(
                      'Job Recruiter Name',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Email
                    Text(
                      'Student@gmail.com',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Edit profile button
                    Container(
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
              _buildDrawerItem(Icons.person_outline, 'Profile Overview'),
              _buildDrawerItem(Icons.work_outline, 'Post Jobs'),
              _buildDrawerItem(Icons.business_center_outlined, 'My Jobs'),
              _buildDrawerItem(Icons.description_outlined, 'Proposals/Applications'),
              _buildDrawerItem(Icons.message_outlined, 'Message'),
              _buildDrawerItem(Icons.people_outline, 'Hired Freelancers'),
              _buildDrawerItem(Icons.star_outline, 'Review & ratings'),
              _buildDrawerItem(Icons.payment_outlined, 'Payments'),
              _buildDrawerItem(Icons.subscriptions_outlined, 'Subscriptions'),
              _buildDrawerItem(Icons.settings_outlined, 'Settings'),
              _buildDrawerItem(Icons.help_outline, 'Help & Support'),
              _buildDrawerItem(Icons.logout, 'Logout'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return Padding(
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      Column(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Summary Cards (Horizontal)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            "109",
                            "Total Jobs",
                            const Color(0xFFEEF2F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            "109",
                            "Ongoing",
                            const Color(0xFFFAEEEE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            "109",
                            "Completed",
                            const Color(0xFFEEF6F0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Recommended Jobs Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recommended Jobs",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            "New Job",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Job Cards (Vertical List)
                    _buildJobCard(
                      context,
                      "Mr. John",
                      "Shopping Fruits",
                      "Shopping",
                      "Shopping is a delightful way to discover new...",
                      "Feb 21, 2023 | 5km | 1 minute to read",
                      "Completed",
                      5000,
                      isCompleted: true,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildJobCard(
                      context,
                      "Mr. John",
                      "Shopping Fruits",
                      "Shopping",
                      "Shopping is a delightful way to discover new...",
                      "Feb 21, 2023 | 5km | 1 minute to read",
                      "Pending",
                      5000,
                      isCompleted: false,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildJobCard(
                      context,
                      "Mr. John",
                      "Shopping Fruits",
                      "Shopping",
                      "Shopping is a delightful way to discover new...",
                      "Feb 21, 2023 | 5km | 1 minute to read",
                      "Completed",
                      5000,
                      isCompleted: true,
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation Bar
            // Container(
            //   height: 70,
            //   decoration: const BoxDecoration(
            //     color: Color.fromARGB(255, 255, 255, 255),
            //     borderRadius: BorderRadius.only(
            //       topLeft: Radius.circular(16),
            //       topRight: Radius.circular(16),
            //     ),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       _buildNavItem(Icons.home, "Home", true, onTap:(){ context.pushNamed(RecruiterHomePage.routeName);}),
            //       _buildNavItem(Icons.work, "My Job", false, onTap:(){ context.pushNamed(MyJobScreen.routeName);}),
            //       _buildNavItem(Icons.add, "Add Job", false, onTap:(){ context.go(JobPostScreen.routePath);}),
            //       _buildNavItem(Icons.person, "Profile", false, onTap:(){ context.pushNamed(RecruiterProfileScreen.routeName);}),
            //     ],
            //   ),
            // ),
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
  }) {
    return GestureDetector(
      onTap: () {
        context.goNamed('jobDetails', pathParameters: {'jobId': jobId});
      },
      child: Container(
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
                          : const Color(0xFFFAEEEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: isCompleted
                            ? Colors.green
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
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
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
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Date info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateInfo,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "\$ $price",
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

class RecruiterJobDetailsScreen extends StatelessWidget {
  final String jobId;
  const RecruiterJobDetailsScreen({required this.jobId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch job details using jobId, or display job info
    return Scaffold(
      appBar: AppBar(title: Text('Job Details')),
      body: Center(
        child: Text('Job ID: $jobId'),
      ),
    );
  }
}