import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../services/user_preferences_service.dart';

class UserDatabase {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final UserPreferencesService _preferencesService = UserPreferencesService();

  // Create a new user in the unified users collection
  Future<void> createUser(AppUser user) async {
    await usersCollection.doc(user.uid).set(user.toMap());
  }

  // Get a user from the unified users collection
  Future<AppUser?> getUser(String uid) async {
    final doc = await usersCollection.doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Update a user in the unified users collection
  Future<void> updateUser(AppUser user) async {
    await usersCollection.doc(user.uid).update(user.toMap());
  }

  // Delete a user from the unified users collection
  Future<void> deleteUser(String uid) async {
    await usersCollection.doc(uid).delete();
  }

  // Stream user data for real-time updates
  Stream<AppUser?> streamUser(String uid) {
    return usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }
  
  // Get all freelancers from the users collection
  Future<List<AppUser>> getAllFreelancers() async {
    final querySnapshot = await usersCollection
        .where('role', isEqualTo: UserPreferencesService.roleFreelancer)
        .get();
        
    return querySnapshot.docs
        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
  
  // Get all recruiters from the users collection
  Future<List<AppUser>> getAllRecruiters() async {
    final querySnapshot = await usersCollection
        .where('role', isEqualTo: UserPreferencesService.roleRecruiter)
        .get();
        
    return querySnapshot.docs
        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
  
  /// Handle a user after Google sign-in, saving their role
  /// This method will create a new user if they don't exist, or update their role if they do
  Future<AppUser> handleGoogleUser(User firebaseUser, String role) async {
    try {
      // Check if user already exists in Firestore
      final existingUser = await getUser(firebaseUser.uid);
      
      if (existingUser != null) {
        // If user exists but role is different, update the role
        if (existingUser.role != role) {
          final updatedUser = AppUser(
            uid: existingUser.uid,
            name: existingUser.name,
            email: existingUser.email,
            role: role,
            phone: existingUser.phone,
            profileImageUrl: existingUser.profileImageUrl,
          );
          
          await updateUser(updatedUser);
          
          // Update role in SharedPreferences
          await _preferencesService.saveUserRole(role);
          await _preferencesService.saveUserId(firebaseUser.uid);
          
          return updatedUser;
        }
        
        // User exists with same role, just save to SharedPreferences
        await _preferencesService.saveUserRole(role);
        await _preferencesService.saveUserId(firebaseUser.uid);
        
        return existingUser;
      } else {
        // Create a new user with the selected role
        final newUser = AppUser(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          role: role,
          profileImageUrl: firebaseUser.photoURL,
        );
        
        // Create user in the unified users collection
        await createUser(newUser);
        
        // Save role and ID in SharedPreferences
        await _preferencesService.saveUserRole(role);
        await _preferencesService.saveUserId(firebaseUser.uid);
        
        return newUser;
      }
    } catch (e) {
      throw Exception('Failed to handle Google user: $e');
    }
  }
  
  // Get freelancer's job statistics (total jobs, earnings, ratings)
  Future<Map<String, dynamic>> getFreelancerStats(String uid) async {
    try {
      // Get total jobs count (jobs where the freelancer is listed as the assignedFreelancer)
      final jobsQuery = await FirebaseFirestore.instance
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
      final ratingsQuery = await FirebaseFirestore.instance
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
  
  // Get jobs applied by the freelancer
  Future<List<String>> getAppliedJobs(String uid) async {
    try {
      final jobsQuery = await FirebaseFirestore.instance
          .collection('jobs')
          .where('applicantIds', arrayContains: uid)
          .get();
      
      return jobsQuery.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }
}
