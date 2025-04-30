import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/models/job_model.dart';
import '../../db/firebase/job.dart';

final jobDatabaseProvider = Provider<JobDatabase>((ref) => JobDatabase());

final jobsProvider = StreamProvider.family<List<Job>, String?>((ref, category) {
  final db = ref.watch(jobDatabaseProvider);
  return db.streamJobs(category: category);
});

// Provider to fetch all jobs without any filtering
final allJobsProvider = StreamProvider<List<Job>>((ref) {
  final db = ref.watch(jobDatabaseProvider);
  return db.streamAllJobs();
});

final recruiterJobsProvider = StreamProvider.family<List<Job>, String>((ref, recruiterId) {
  final db = ref.watch(jobDatabaseProvider);
  return db.streamRecruiterJobs(recruiterId);
});

final freelancerJobsProvider = StreamProvider.family<List<Job>, String>((ref, freelancerId) {
  final db = ref.watch(jobDatabaseProvider);
  return db.streamFreelancerJobs(freelancerId);
});

final selectedJobProvider = StateProvider<Job?>((ref) => null);

class JobNotifier extends StateNotifier<AsyncValue<Job?>> {
  final JobDatabase _db;
  
  JobNotifier(this._db) : super(const AsyncValue.loading());
  
  Future<void> createJob(Job job) async {
    state = const AsyncValue.loading();
    try {
      final id = await _db.createJob(job);
      state = AsyncValue.data(job.copyWith(id: id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> getJob(String jobId) async {
    state = const AsyncValue.loading();
    try {
      final job = await _db.getJob(jobId);
      state = AsyncValue.data(job);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateJob(Job job) async {
    state = const AsyncValue.loading();
    try {
      await _db.updateJob(job);
      state = AsyncValue.data(job);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> deleteJob(String jobId) async {
    state = const AsyncValue.loading();
    try {
      await _db.deleteJob(jobId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> applyForJob(String jobId, String freelancerId) async {
    try {
      await _db.applyForJob(jobId, freelancerId);
      if (state.value != null) {
        // Update the local state if we have a job loaded
        final currentJob = state.value!;
        final List<String> applicantIds = [
          ...(currentJob.applicantIds ?? []), 
          freelancerId
        ];
        state = AsyncValue.data(currentJob.copyWith(applicantIds: applicantIds));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _db.updateJobStatus(jobId, status);
      if (state.value != null && state.value!.id == jobId) {
        // Update the local state if we have this job loaded
        state = AsyncValue.data(state.value!.copyWith(status: status));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final jobNotifierProvider = StateNotifierProvider<JobNotifier, AsyncValue<Job?>>((ref) {
  final db = ref.watch(jobDatabaseProvider);
  return JobNotifier(db);
});