import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import 'auth_service.dart';

class FeedbackService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  final AuthService _authService = AuthService();

  /// Posts feedback to the API.
  /// Expects feedback category, subject, and message.
  Future<Map<String, dynamic>> submitFeedback({
    required String category,
    required String subject,
    required String message,
  }) async {
    try {
      // Get auth cookie for authenticated request
      final auth_token = await _authService.getToken();

      final response = await _dio.post(
        "/feedback",
        data: {
          "category": category,
          "subject": subject,
          "message": message,
        },
        options: Options(
          headers: {
            if (auth_token != null) "Cookie": "$auth_token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception("Failed to submit feedback. Status code: ${response.statusCode}");
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
