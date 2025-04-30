import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String category;
  final String contactNo;
  final String location;
  final DateTime date;
  final double price;
  final String? imageUrl;
  final String recruiterId;
  final String? recruiterName;
  final String? recruiterImageUrl;
  final List<String>? applicantIds;
  final String status; // 'open', 'in-progress', 'completed', 'cancelled'

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.contactNo,
    required this.location,
    required this.date,
    required this.price,
    required this.recruiterId,
    this.imageUrl,
    this.recruiterName,
    this.recruiterImageUrl,
    this.applicantIds,
    this.status = 'open',
  });

  factory Job.fromMap(Map<String, dynamic> data, String documentId) {
    return Job(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      contactNo: data['contactNo'] ?? '',
      location: data['location'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      price: (data['price'] ?? 0).toDouble(),
      recruiterId: data['recruiterId'] ?? '',
      imageUrl: data['imageUrl'],
      recruiterName: data['recruiterName'],
      recruiterImageUrl: data['recruiterImageUrl'],
      applicantIds: data['applicantIds'] != null 
          ? List<String>.from(data['applicantIds']) 
          : null,
      status: data['status'] ?? 'open',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'contactNo': contactNo,
      'location': location,
      'date': Timestamp.fromDate(date),
      'price': price,
      'recruiterId': recruiterId,
      'imageUrl': imageUrl,
      'recruiterName': recruiterName,
      'recruiterImageUrl': recruiterImageUrl,
      'applicantIds': applicantIds,
      'status': status,
    };
  }

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? contactNo,
    String? location,
    DateTime? date,
    double? price,
    String? recruiterId,
    String? imageUrl,
    String? recruiterName,
    String? recruiterImageUrl,
    List<String>? applicantIds,
    String? status,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      contactNo: contactNo ?? this.contactNo,
      location: location ?? this.location,
      date: date ?? this.date,
      price: price ?? this.price,
      recruiterId: recruiterId ?? this.recruiterId,
      imageUrl: imageUrl ?? this.imageUrl,
      recruiterName: recruiterName ?? this.recruiterName,
      recruiterImageUrl: recruiterImageUrl ?? this.recruiterImageUrl,
      applicantIds: applicantIds ?? this.applicantIds,
      status: status ?? this.status,
    );
  }
}

