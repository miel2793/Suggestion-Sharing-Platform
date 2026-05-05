class Suggestion {
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
  final UploadedBy uploadedBy;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Suggestion({
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
    required this.uploadedBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
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
      uploadedBy: UploadedBy.fromJson(json['uploaded_by'] ?? {}),
      status: json['status'] ?? 'approved',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'course_code': courseCode,
      'course_name': courseName,
      'dept': dept,
      'intake': intake,
      'section': section,
      'exam_type': examType,
      'description': description,
      'attachment_url': attachmentUrl,
      'stars': stars,
      'status': status,
      'uploaded_by': uploadedBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class UploadedBy {
  final String id;
  final String name;
  final String email;
  final String? studentId;
  final String? imgUrl;
  final String? dept;
  final String? intake;
  final String? role;

  UploadedBy({
    required this.id,
    required this.name,
    required this.email,
    this.studentId,
    this.imgUrl,
    this.dept,
    this.intake,
    this.role,
  });

  factory UploadedBy.fromJson(dynamic json) {
    if (json is String) {
      return UploadedBy(
        id: json,
        name: 'User $json',
        email: '',
      );
    }
    
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};
    
    return UploadedBy(
      id: data['_id'] ?? '',
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      studentId: data['student_id'] ?? data['user_id'] ?? '',
      imgUrl: data['img_url'] ?? 
              data['profile_image'] ?? 
              data['profile_img'] ?? 
              data['image'] ?? 
              data['img'] ?? 
              data['profile_pic'],
      dept: data['dept'] ?? data['department'],
      intake: data['intake'],
      role: data['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'student_id': studentId,
      'img_url': imgUrl,
      'dept': dept,
      'intake': intake,
      'role': role,
    };
  }
}