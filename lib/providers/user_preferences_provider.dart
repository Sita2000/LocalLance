import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_preferences_service.dart';

// Provider for UserPreferencesService
final userPreferencesServiceProvider = Provider<UserPreferencesService>((ref) {
  return UserPreferencesService();
});

// Provider to access the current user role
final userRoleProvider = FutureProvider<String?>((ref) {
  final prefsService = ref.watch(userPreferencesServiceProvider);
  return prefsService.getUserRole();
});

// Provider to access the current user ID
final userIdProvider = FutureProvider<String?>((ref) {
  final prefsService = ref.watch(userPreferencesServiceProvider);
  return prefsService.getUserId();
});