import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RecruiterBottomNavItem {
  home,
  postJob,
  profile,
}

class RecruiterBottomNavNotifier extends StateNotifier<RecruiterBottomNavItem> {
  RecruiterBottomNavNotifier() : super(RecruiterBottomNavItem.home);

  void setSelectedItem(RecruiterBottomNavItem item) {
    state = item;
  }
}

final recruiterBottomNavProvider = StateNotifierProvider<RecruiterBottomNavNotifier, RecruiterBottomNavItem>((ref) {
  return RecruiterBottomNavNotifier();
});