import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/explore_suggestion_model.dart';
class SuggestionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Suggestion>> fetchSuggestions() async {
    try {
      final response = await _dio.get("/suggestions");

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        List<dynamic> data;
        if (rawData is String) {
          data = jsonDecode(rawData);
        } else {
          data = rawData;
        }
        return data
            .map((json) => Suggestion.fromJson(json))
            .toList();
      } else {
        throw Exception("Failed to load suggestions");
      }
    } on DioException catch (e) {
      throw Exception("Dio Error: ${e.message}");
    }
  }
}