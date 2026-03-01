import 'package:dio/dio.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/Services/auth_service.dart';

class UploadSuggestionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://sdp-3-backend.vercel.app/api",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final AuthService _authService = AuthService();

  /// Uploads a new suggestion with an attached file.
  /// Returns the response data on success.
  Future<Map<String, dynamic>> uploadSuggestion({
    required String filePath,
    required String fileName,
    required String courseCode,
    required String courseName,
    required String dept,
    required String intake,
    required String section,
    required String examType,
    required String description,
  }) async {
    try {
      // Get auth cookie for authenticated request
      final cookie = await _authService.getToken();

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        "course_code": courseCode,
        "course_name": courseName,
        "dept": dept,
        "intake": intake,
        "section": section,
        "exam_type": examType,
        "description": description,
      });

      final response = await _dio.post(
        "/suggestions",
        data: formData,
        options: Options(
          headers: {
            if (cookie != null) "Cookie": cookie,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception("Upload failed. Please try again.");
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception("Network error. Please check your connection.");
    }
  }
}
