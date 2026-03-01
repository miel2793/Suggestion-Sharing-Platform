class UserProfile {
  final String name;
  final String email;
  final String role;
  final String dept;
  final String intake;
  final String section;
  final List<UserUpload> uploads;
  final DateTime createdAt;

  UserProfile({
    required this.name,
    required this.email,
    required this.role,
    required this.dept,
    required this.intake,
    required this.section,
    required this.uploads,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      dept: json['dept'] ?? '',
      intake: json['intake'] ?? '',
      section: json['section'] ?? '',
      uploads: (json['uploads'] as List<dynamic>?)
              ?.map((e) => UserUpload.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class UserUpload {
  final String id;
  final String courseCode;
  final String courseName;
  final String dept;
  final String intake;
  final String section;
  final String examType;
  final String description;
  final String attachmentUrl;
  final int stars;
  final String status;
  final DateTime createdAt;

  UserUpload({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.dept,
    required this.intake,
    required this.section,
    required this.examType,
    required this.description,
    required this.attachmentUrl,
    required this.stars,
    required this.status,
    required this.createdAt,
  });

  factory UserUpload.fromJson(Map<String, dynamic> json) {
    return UserUpload(
      id: json['_id'] ?? '',
      courseCode: json['course_code'] ?? '',
      courseName: json['course_name'] ?? '',
      dept: json['dept'] ?? '',
      intake: json['intake'] ?? '',
      section: json['section'] ?? '',
      examType: json['exam_type'] ?? '',
      description: json['description'] ?? '',
      attachmentUrl: json['attachment_url'] ?? '',
      stars: json['stars'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
