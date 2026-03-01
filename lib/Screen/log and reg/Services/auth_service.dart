import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_cookie';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://sdp-3-backend.vercel.app/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // ─── LOGIN ────────────────────────────────────────────────────────

  /// Logs in with [email] and [password].
  /// Saves the auth cookie from the response headers.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract and save the Set-Cookie header
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          await _saveCookie(cookies.first);
        }

        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception("Login failed. Please try again.");
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

  // ─── REGISTER ─────────────────────────────────────────────────────

  /// Registers a new user.
  Future<Map<String, dynamic>> register({
    required String name,
    required String userId,
    required String email,
    required String password,
    required String dept,
    required String intake,
    required String section,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/register",
        data: {
          "name": name,
          "user_id": userId,
          "email": email,
          "password": password,
          "dept": dept,
          "intake": intake,
          "section": section,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception("Registration failed. Please try again.");
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

  // ─── PROFILE ───────────────────────────────────────────────────────

  /// Fetches the current user's profile from the API.
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final cookie = await getToken();
      final response = await _dio.get(
        "/auth/me",
        options: Options(
          headers: {
            if (cookie != null) "Cookie": cookie,
          },
        ),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception("Failed to load profile.");
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

  // ─── TOKEN / SESSION HELPERS ──────────────────────────────────────

  Future<void> _saveCookie(String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, cookie);
  }

  /// Returns the saved auth cookie, or `null` if not logged in.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Returns `true` if the user has a saved auth cookie.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Calls the logout API and clears the saved auth cookie.
  Future<void> logout() async {
    try {
      final cookie = await getToken();
      await _dio.post(
        "/auth/logout",
        options: Options(
          headers: {
            if (cookie != null) "Cookie": cookie,
          },
        ),
      );
    } catch (_) {
      // Even if API call fails, still clear local cookie
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
