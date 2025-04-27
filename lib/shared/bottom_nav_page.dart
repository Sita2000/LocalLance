import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mylocallance/views/job_recruiter/home_screen.dart';
import 'package:mylocallance/views/job_recruiter/job_post_screen.dart';
import 'package:mylocallance/views/job_recruiter/myjob_screen.dart';
import 'package:mylocallance/views/job_recruiter/profile_screen.dart';
import '../providers/bottom_nav_provider.dart';

class BottomNavPage extends ConsumerWidget {
  static const String routePath = '/bottom_nav';
  static const String routeName = 'Bottom Navigation';
  const BottomNavPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = ref.watch(bottomNavProvider);

    return Scaffold(
      body: _buildPage(selectedItem),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedItem.index,
        onDestinationSelected: (index) {
          ref.read(bottomNavProvider.notifier).setSelectedItem(
                BottomNavItem.values[index],
              );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'My Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add Job',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BottomNavItem selectedItem) {
    switch (selectedItem) {
      case BottomNavItem.home:
        return const RecruiterHomePage();
      case BottomNavItem.myJob:
        return const MyJobScreen();
      case BottomNavItem.addJob:
        return const JobPostScreen();
      case BottomNavItem.profile:
        return const RecruiterProfileScreen();
    }
  }
}
