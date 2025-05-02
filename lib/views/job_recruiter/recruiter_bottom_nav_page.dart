import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mylocallance/providers/recruiter_bottom_nav_provider.dart';
import 'package:mylocallance/views/job_recruiter/home_screen.dart';
import 'package:mylocallance/views/job_recruiter/job_post_screen.dart';
import 'package:mylocallance/views/job_recruiter/profile_screen.dart';

class RecruiterBottomNavPage extends ConsumerStatefulWidget {
  static const String routePath = '/recruiter_bottom_nav';
  static const String routeName = 'Recruiter Bottom Navigation';
  final Widget? child;
  
  const RecruiterBottomNavPage({
    super.key,
    this.child,
  });

  @override
  ConsumerState<RecruiterBottomNavPage> createState() => _RecruiterBottomNavPageState();
}

class _RecruiterBottomNavPageState extends ConsumerState<RecruiterBottomNavPage> {
  @override
  Widget build(BuildContext context) {
    final selectedItem = ref.watch(recruiterBottomNavProvider);
    
    return Scaffold(
      body: _buildPage(selectedItem),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedItem.index,
        onDestinationSelected: (index) {
          final selectedNavItem = RecruiterBottomNavItem.values[index];
          
          // Update the provider state
          ref.read(recruiterBottomNavProvider.notifier).setSelectedItem(selectedNavItem);

       
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Post Job',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEEF2F6),
        elevation: 8,
      ),
    );
  }

  Widget _buildPage(RecruiterBottomNavItem selectedItem) {
    log("Building page for: $selectedItem");
    switch (selectedItem) {
      case RecruiterBottomNavItem.home:
        return const RecruiterHomePage();
      case RecruiterBottomNavItem.postJob:
        return const JobPostScreen();
      case RecruiterBottomNavItem.profile:
        return const RecruiterProfileScreen();
    }
  }
}