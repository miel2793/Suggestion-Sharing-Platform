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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['_id'],
      courseCode: json['course_code'],
      courseName: json['course_name'],
      dept: json['dept'],
      intake: json['intake'],
      section: json['section'],
      examType: json['exam_type'],
      description: json['description'] ?? '',
      attachmentUrl: json['attachment_url'],
      stars: json['stars'] ?? 0,
      uploadedBy: UploadedBy.fromJson(json['uploaded_by']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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

  UploadedBy({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UploadedBy.fromJson(Map<String, dynamic> json) {
    return UploadedBy(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}