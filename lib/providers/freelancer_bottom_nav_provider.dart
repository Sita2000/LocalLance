import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FreelancerBottomNavItem {
  home,
  jobs,
  profile,
}

class FreelancerBottomNavNotifier extends StateNotifier<FreelancerBottomNavItem> {
  FreelancerBottomNavNotifier() : super(FreelancerBottomNavItem.home);

  void setSelectedItem(FreelancerBottomNavItem item) {
    state = item;
  }
}

final freelancerBottomNavProvider = StateNotifierProvider<FreelancerBottomNavNotifier, FreelancerBottomNavItem>((ref) {
  return FreelancerBottomNavNotifier();
}); 