import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/firebase/freelancer_db.dart';
import '../services/user_preferences_service.dart';

// Provider to fetch freelancer profile data using the FreelancerDatabase service
final freelancerProfileProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  final freelancerDB = ref.watch(freelancerDatabaseProvider);
  return freelancerDB.getFreelancerProfile(uid);
});

// Provider to get freelancer's job statistics using the FreelancerDatabase service
final freelancerStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
  final freelancerDB = ref.watch(freelancerDatabaseProvider);
  return freelancerDB.getFreelancerStats(uid);
});

// Provider to get list of jobs applied by the freelancer
final freelancerAppliedJobsProvider = FutureProvider.family<List<String>, String>((ref, uid) async {
  final freelancerDB = ref.watch(freelancerDatabaseProvider);
  return freelancerDB.getAppliedJobs(uid);
});

// Provider to get current freelancer ID from SharedPreferences
final currentFreelancerIdProvider = FutureProvider<String?>((ref) async {
  final prefsService = UserPreferencesService();
  final userRole = await prefsService.getUserRole();
  
  if (userRole == UserPreferencesService.roleFreelancer) {
    return prefsService.getUserId();
  }
  
  return null;
});