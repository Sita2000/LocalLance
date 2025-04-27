import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BottomNavItem {
  home,
  myJob,
  addJob,
  profile,
}

class BottomNavNotifier extends StateNotifier<BottomNavItem> {
  BottomNavNotifier() : super(BottomNavItem.home);

  void setSelectedItem(BottomNavItem item) {
    state = item;
  }
}

final bottomNavProvider = StateNotifierProvider<BottomNavNotifier, BottomNavItem>((ref) {
  return BottomNavNotifier();
}); 