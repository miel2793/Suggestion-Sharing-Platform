import 'package:dio/dio.dart';
import '../model/explore_suggestion_model.dart';
class SuggestionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://sdp-3-backend.vercel.app/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Suggestion>> fetchSuggestions() async {
    try {
      final response = await _dio.get("/suggestions");

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
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