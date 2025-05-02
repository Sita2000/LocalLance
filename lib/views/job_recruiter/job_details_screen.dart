import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../controllers/job_controller.dart';
import '../../db/models/job_model.dart';

// Provider for job details loading state
final jobDetailsLoadingProvider = StateProvider<bool>((ref) => false);

// Provider to cache the current job being viewed to prevent unnecessary fetches
final currentJobProvider = StateProvider<String?>((ref) => null);

// Provider for job action result
final jobActionResultProvider = StateProvider<JobActionResult?>((ref) => null);

// Class to hold result of job actions (update/delete)
class JobActionResult {
  final bool success;
  final String message;
  final String action;

  JobActionResult({
    required this.success, 
    required this.message,
    required this.action
  });
}

class JobDetailsScreen extends ConsumerStatefulWidget {
  static const String routeName = 'recruiter.JobDetailsScreen';
  static const String routePath = '/recruiter/job_details';
  
  final String jobId;
  
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch job details in initState to prevent fetch during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJobDetails();
    });
  }

  @override
  void didUpdateWidget(JobDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch if jobId changes
    if (oldWidget.jobId != widget.jobId) {
      _fetchJobDetails();
    }
  }

  Future<void> _fetchJobDetails() async {
    try {
      // Check if we're already viewing this job
      final currentJobId = ref.read(currentJobProvider);
      if (currentJobId != widget.jobId) {
        // Set loading state
        ref.read(jobDetailsLoadingProvider.notifier).state = true;
        // Update the current job ID
        ref.read(currentJobProvider.notifier).state = widget.jobId;
        // Fetch job details
        await ref.read(jobNotifierProvider.notifier).getJob(widget.jobId);
      }
    } catch (e) {
      // Set action result for error
      ref.read(jobActionResultProvider.notifier).state = JobActionResult(
        success: false,
        message: 'Failed to load job: ${e.toString()}',
        action: 'fetch'
      );
    } finally {
      // Set loading state to false if widget is still mounted
      if (mounted) {
        ref.read(jobDetailsLoadingProvider.notifier).state = false;
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Job job) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this job? This action cannot be undone.',
            style: GoogleFonts.roboto(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.roboto(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteJob(context, ref, job.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStatusDialog(BuildContext context, WidgetRef ref, Job job) {
    String selectedStatus = job.status;
    final statuses = ['open', 'in-progress', 'completed', 'cancelled'];
    final statusLabels = {
      'open': 'Active',
      'in-progress': 'In Progress',
      'completed': 'Completed', 
      'cancelled': 'Cancelled'
    };
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Update Job Status',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current status: ${statusLabels[job.status] ?? job.status}',
                    style: GoogleFonts.roboto(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'New Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: statuses.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          statusLabels[status] ?? status.substring(0, 1).toUpperCase() + status.substring(1),
                          style: GoogleFonts.roboto(),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.roboto(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _updateJobStatus(context, ref, job.id, selectedStatus);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                  ),
                  child: Text(
                    'Update',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _updateJobStatus(BuildContext context, WidgetRef ref, String jobId, String status) async {
    // Set loading state to true
    ref.read(jobDetailsLoadingProvider.notifier).state = true;
    
    try {
      // Call Firebase to update job status
      await ref.read(jobNotifierProvider.notifier).updateJobStatus(jobId, status);
      
      // Set success result
      ref.read(jobActionResultProvider.notifier).state = JobActionResult(
        success: true,
        message: 'Job status updated successfully',
        action: 'update'
      );
    } catch (e) {
      // Set error result
      ref.read(jobActionResultProvider.notifier).state = JobActionResult(
        success: false,
        message: 'Error updating job status: ${e.toString()}',
        action: 'update'
      );
    } finally {
      // Set loading state to false
      if (mounted) {
        ref.read(jobDetailsLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _deleteJob(BuildContext context, WidgetRef ref, String jobId) async {
    // Set loading state to true
    ref.read(jobDetailsLoadingProvider.notifier).state = true;
    
    try {
      // Call Firebase to delete the job
      await ref.read(jobNotifierProvider.notifier).deleteJob(jobId);
      
      // Set success result
      ref.read(jobActionResultProvider.notifier).state = JobActionResult(
        success: true,
        message: 'Job deleted successfully',
        action: 'delete'
      );
      
      // Navigate back to jobs list
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      // Set error result
      ref.read(jobActionResultProvider.notifier).state = JobActionResult(
        success: false,
        message: 'Error deleting job: ${e.toString()}',
        action: 'delete'
      );
    } finally {
      // Set loading state to false
      if (mounted) {
        ref.read(jobDetailsLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the job from state
    final jobState = ref.watch(jobNotifierProvider);
    
    // Get the loading state
    final isLoading = ref.watch(jobDetailsLoadingProvider);
    
    // Get action result
    final actionResult = ref.watch(jobActionResultProvider);
    
    // Show snackbar if there's an action result
    if (actionResult != null && context.mounted) {
      // Wait a moment to show SnackBar after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(actionResult.message),
            backgroundColor: actionResult.success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Clear the action result
        ref.read(jobActionResultProvider.notifier).state = null;
      });
    }

    // Create a safe job details screen with error handling
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Job Details',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'delete' && jobState.value != null) {
                _showDeleteConfirmationDialog(context, ref, jobState.value!);
              } else if (value == 'status' && jobState.value != null) {
                _showUpdateStatusDialog(context, ref, jobState.value!);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    const Icon(Icons.update, color: Color(0xFF2C3E50)),
                    const SizedBox(width: 8),
                    Text('Update Status', style: GoogleFonts.roboto()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Delete Job', style: GoogleFonts.roboto()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Content with error handling
          jobState.when(
            data: (job) {
              if (job == null) {
                return const Center(
                  child: Text('Job not found or has been removed'),
                );
              }
              
              // Safely handle date formatting with try-catch
              String formattedDate;
              try {
                formattedDate = DateFormat('MMM d, yyyy').format(job.date);
              } catch (e) {
                formattedDate = 'Date unavailable';
              }
              
              // Get status info
              Color statusColor;
              String statusText = job.status;
              
              switch (job.status) {
                case 'open':
                  statusColor = Colors.blue;
                  statusText = 'Active';
                  break;
                case 'in-progress':
                  statusColor = Colors.orange;
                  statusText = 'In Progress';
                  break;
                case 'completed':
                  statusColor = Colors.green;
                  statusText = 'Completed';
                  break;
                case 'cancelled':
                  statusColor = Colors.red;
                  statusText = 'Cancelled';
                  break;
                default:
                  statusColor = Colors.grey;
              }
              
              // Get category icon with null safety
              IconData categoryIcon;
              try {
                switch (job.category.toLowerCase()) {
                  case 'cleaning':
                    categoryIcon = Icons.cleaning_services;
                    break;
                  case 'gardening':
                    categoryIcon = Icons.yard;
                    break;
                  case 'plumbing':
                    categoryIcon = Icons.plumbing;
                    break;
                  case 'electrical':
                    categoryIcon = Icons.electrical_services;
                    break;
                  case 'carpentry':
                    categoryIcon = Icons.handyman;
                    break;
                  case 'painting':
                    categoryIcon = Icons.format_paint;
                    break;
                  case 'moving':
                    categoryIcon = Icons.local_shipping;
                    break;
                  case 'delivery':
                    categoryIcon = Icons.local_shipping;
                    break;
                  case 'computer repair':
                    categoryIcon = Icons.computer;
                    break;
                  case 'web development':
                    categoryIcon = Icons.web;
                    break;
                  default:
                    categoryIcon = Icons.work;
                }
              } catch (e) {
                categoryIcon = Icons.work;
              }
              
              // Main content
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Card
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Icon
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 16.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                categoryIcon,
                                color: const Color(0xFF2C3E50),
                                size: 32,
                              ),
                            ),
                          ),
                          
                          // Job Title and Category
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              children: [
                                Text(
                                  job.title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.category,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Price and Status
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        '₹',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        job.price.toStringAsFixed(0),
                                        style: GoogleFonts.roboto(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        statusText,
                                        style: GoogleFonts.roboto(
                                          color: statusColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Date Posted
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Posted on $formattedDate',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Description Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  job.description,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Divider(),
                          
                          // Applicants Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Applicants',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (job.applicantIds == null || job.applicantIds!.isEmpty)
                                  Text(
                                    'No applications yet',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      Text(
                                        '${job.applicantIds!.length} ${job.applicantIds!.length == 1 ? 'applicant' : 'applicants'} for this job',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.info_outline,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'View and contact applicants in your messages',
                                                style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          
                          const Divider(),
                          
                          // Location Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Job Location',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 24,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          job.location,
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Divider(),
                          
                          // Contact Information Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Number',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      job.contactNo,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Actions Row
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showUpdateStatusDialog(context, ref, job),
                                    icon: const Icon(Icons.update),
                                    label: Text(
                                      'Update Status',
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2C3E50),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _showDeleteConfirmationDialog(context, ref, job),
                                  icon: const Icon(Icons.delete),
                                  label: Text(
                                    'Delete',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading job details',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchJobDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
