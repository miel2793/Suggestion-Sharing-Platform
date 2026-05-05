import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/explore_suggestion_model.dart';
import 'auth_service.dart';

class ModerationService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  final AuthService _authService = AuthService();

  /// Gets all suggestions for moderation
  Future<List<Suggestion>> fetchAllSuggestions() async {
    try {
      final cookie = await _authService.getToken();

      final response = await _dio.get(
        "/manage/suggestions",
        options: Options(
          headers: {
            if (cookie != null) "Cookie": cookie,
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = _safeList(response.data);
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => Suggestion.fromJson(json))
            .toList();
      } else {
        throw Exception("Failed to load moderation suggestions");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Updates suggestion status using multipart/form-data
  Future<void> updateSuggestionStatus(String id, String status) async {
    try {
      final cookie = await _authService.getToken();
      
      final formData = FormData.fromMap({
        "status": status,
      });

      final response = await _dio.put(
        "/manage/suggestions/$id",
        data: formData,
        options: Options(
          headers: {
            if (cookie != null) "Cookie": cookie,
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to update suggestion status");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
    }
    return e.message ?? "Unexpected network error";
  }

  List<dynamic> _safeList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) return decoded;
        if (decoded is Map) return [decoded];
      } catch (e) {
        return [];
      }
    }
    if (data is Map<String, dynamic>) return [data];
    return [];
  }
}
