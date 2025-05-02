import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to manage user preferences including role and auth state
class UserPreferencesService {
  // Constants for keys
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  
  // Constants for role values
  static const String roleFreelancer = 'freelancer';
  static const String roleRecruiter = 'recruiter';
  
  /// Save user role to shared preferences
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }
  
  /// Get user role from shared preferences
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }
  
  /// Save user ID to shared preferences
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }
  
  /// Get user ID from shared preferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
  
  /// Clear all user data from shared preferences on logout
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
  }
  
  /// Check if user is authenticated by checking if user ID exists
  Future<bool> isAuthenticated() async {
    final userId = await getUserId();
    return userId != null;
  }
}

/// Provider for UserPreferencesService
final userPreferencesServiceProvider = Provider<UserPreferencesService>((ref) {
  return UserPreferencesService();
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final prefsService = ref.watch(userPreferencesServiceProvider);
  return prefsService.isAuthenticated();
});

/// Provider to get the current user role
final userRoleProvider = FutureProvider<String?>((ref) async {
  final prefsService = ref.watch(userPreferencesServiceProvider);
  return prefsService.getUserRole();
});

/// Provider to get the current user ID
final userIdProvider = FutureProvider<String?>((ref) async {
  final prefsService = ref.watch(userPreferencesServiceProvider);
  return prefsService.getUserId();
});