import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mylocallance/providers/freelancer_bottom_nav_provider.dart';
import 'package:mylocallance/views/freelancer/chatlist_screen.dart';
import 'package:mylocallance/views/freelancer/dashboard.dart';
import 'package:mylocallance/views/freelancer/my_job_screen.dart';
import 'package:mylocallance/views/freelancer/profile_screen.dart';

class FreelancerBottomNavPage extends ConsumerWidget {
  static const String routePath = '/freelancer_bottom_nav';
  static const String routeName = 'Freelancer Bottom Navigation';
  const FreelancerBottomNavPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = ref.watch(freelancerBottomNavProvider);

    return Scaffold(
      body: _buildPage(selectedItem),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedItem.index,
        onDestinationSelected: (index) {
          ref.read(freelancerBottomNavProvider.notifier).setSelectedItem(
                FreelancerBottomNavItem.values[index],
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
            label: 'Jobs',
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

  Widget _buildPage(FreelancerBottomNavItem selectedItem) {
    switch (selectedItem) {
      case FreelancerBottomNavItem.home:
        return const FreelancerDashboard(); // TODO: Replace with FreelancerHomePage
      case FreelancerBottomNavItem.jobs:
        return const FreelancerMyJobScreen(); // TODO: Replace with FreelancerJobsScreen
       case FreelancerBottomNavItem.profile:
        return const FreelancerProfileScreen(); // TODO: Replace with FreelancerProfileScreen
    }
  }
}
