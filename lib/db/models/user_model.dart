// User model for Firestore
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'job_recruiter' or 'freelancer'
  final String? phone;
  final String? profileImageUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImageUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      uid: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      phone: data['phone'],
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
    };
  }
}
