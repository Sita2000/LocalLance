import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service class for handling freelancer-related database operations
class FreelancerDatabase {
  final FirebaseFirestore _firestore;

  FreelancerDatabase({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get freelancer profile data from Firestore
  Future<Map<String, dynamic>?> getFreelancerProfile(String uid) async {
    try {
      final doc = await _firestore.collection('freelancers').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load freelancer profile: $e');
    }
  }

  /// Update freelancer profile data in Firestore
  Future<void> updateFreelancerProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('freelancers').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update freelancer profile: $e');
    }
  }

  /// Create freelancer profile in Firestore
  Future<void> createFreelancerProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('freelancers').doc(uid).set(data);
    } catch (e) {
      throw Exception('Failed to create freelancer profile: $e');
    }
  }

  /// Get freelancer's job statistics (total jobs, earnings, ratings)
  Future<Map<String, dynamic>> getFreelancerStats(String uid) async {
    try {
      // Get total jobs count (jobs where the freelancer is listed as the assignedFreelancer)
      final jobsQuery = await _firestore
          .collection('jobs')
          .where('assignedFreelancerId', isEqualTo: uid)
          .get();
      
      int totalJobs = jobsQuery.docs.length;
      int completedJobs = 0;
      
      // Calculate total earnings
      double totalEarnings = 0;
      for (var doc in jobsQuery.docs) {
        final jobData = doc.data();
        if (jobData['status'] == 'completed' && jobData['price'] != null) {
          totalEarnings += (jobData['price'] as num).toDouble();
          completedJobs++;
        }
      }
      
      // Get average rating
      final ratingsQuery = await _firestore
          .collection('ratings')
          .where('freelancerId', isEqualTo: uid)
          .get();
      
      double averageRating = 0;
      if (ratingsQuery.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in ratingsQuery.docs) {
          totalRating += (doc.data()['rating'] as num).toDouble();
        }
        averageRating = totalRating / ratingsQuery.docs.length;
      }
      
      return {
        'totalJobs': totalJobs,
        'completedJobs': completedJobs,
        'earnings': totalEarnings,
        'rating': averageRating,
      };
    } catch (e) {
      // Return default values in case of error
      return {
        'totalJobs': 0,
        'completedJobs': 0,
        'earnings': 0.0,
        'rating': 0.0,
      };
    }
  }
  
  /// Get jobs applied by the freelancer
  Future<List<String>> getAppliedJobs(String uid) async {
    try {
      final jobsQuery = await _firestore
          .collection('jobs')
          .where('applicantIds', arrayContains: uid)
          .get();
      
      return jobsQuery.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }
}

/// Provider for FreelancerDatabase service
final freelancerDatabaseProvider = Provider<FreelancerDatabase>((ref) {
  return FreelancerDatabase();
});