import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobDatabase {
  final CollectionReference jobsCollection =
      FirebaseFirestore.instance.collection('jobs');

  // Create a new job
  Future<String> createJob(Job job) async {
    DocumentReference docRef = await jobsCollection.add(job.toMap());
    return docRef.id;
  }

  // Get a single job by ID
  Future<Job?> getJob(String jobId) async {
    final doc = await jobsCollection.doc(jobId).get();
    if (doc.exists) {
      return Job.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Update job details
  Future<void> updateJob(Job job) async {
    await jobsCollection.doc(job.id).update(job.toMap());
  }

  // Delete a job
  Future<void> deleteJob(String jobId) async {
    await jobsCollection.doc(jobId).delete();
  }

  // Get all jobs (with optional category filter)
  Stream<List<Job>> streamJobs({String? category}) {
    Query query = jobsCollection.orderBy('date', descending: true);
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Job.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get jobs posted by a specific recruiter
  Stream<List<Job>> streamRecruiterJobs(String recruiterId) {
    return jobsCollection
        .where('recruiterId', isEqualTo: recruiterId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Job.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get jobs applied to by a specific freelancer
  Stream<List<Job>> streamFreelancerJobs(String freelancerId) {
    return jobsCollection
        .where('applicantIds', arrayContains: freelancerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Job.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Apply for a job (add freelancer ID to applicants)
  Future<void> applyForJob(String jobId, String freelancerId) async {
    await jobsCollection.doc(jobId).update({
      'applicantIds': FieldValue.arrayUnion([freelancerId])
    });
  }

  // Update job status
  Future<void> updateJobStatus(String jobId, String status) async {
    await jobsCollection.doc(jobId).update({'status': status});
  }

  // Get all jobs without any filtering
  Stream<List<Job>> streamAllJobs() {
    return jobsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Job.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}