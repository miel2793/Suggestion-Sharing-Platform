import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';



class AuthService {
  static const String _tokenKey = 'auth_cookie';
  
  // Static cache to store profile data across different instances
  static Map<String, dynamic>? _profileCache;
  static bool? _isLoggedInCached;
  static bool _isFetchingProfile = false;

  /// Synchronous access to cached profile data
  static Map<String, dynamic>? get cachedProfile => _profileCache;
  
  /// Synchronous access to cached login status
  static bool? get cachedIsLoggedIn => _isLoggedInCached;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
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
        
        _isLoggedInCached = true;
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
  Future<Map<String, dynamic>> getProfile({bool forceRefresh = false}) async {
    // If not forced and we have cache, return it immediately
    if (!forceRefresh && _profileCache != null) {
       return _profileCache!;
    }

    // prevent duplicate simultaneous requests
    if (_isFetchingProfile && _profileCache == null) {
      // wait a bit and check again? for simplicity, let it proceed
    }

    try {
      _isFetchingProfile = true;
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
        _profileCache = Map<String, dynamic>.from(response.data);
        return _profileCache!;
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
    } finally {
      _isFetchingProfile = false;
    }
  }

  // ─── UPDATE PROFILE ────────────────────────────────────────────────

  /// Updates the current user's profile on the backend.
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String dept,
    required String intake,
    required String section,
  }) async {
    try {
      final cookie = await getToken();
      final response = await _dio.put(
        "/auth/update-profile",
        data: {
          "name": name,
          "dept": dept,
          "intake": intake,
          "section": section,
        },
        options: Options(
          headers: {
            if (cookie != null) "Cookie": cookie,
          },
        ),
      );

      if (response.statusCode == 200) {
        // Update local cache if available
        if (_profileCache != null) {
          _profileCache!['name'] = name;
          _profileCache!['dept'] = dept;
          _profileCache!['intake'] = intake;
          _profileCache!['section'] = section;
        }
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception("Failed to update profile.");
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

  // ─── CHANGE PASSWORD ──────────────────────────────────────────────

  /// Changes the user's password.
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final cookie = await getToken();
      final response = await _dio.post(
        "/auth/change-password",
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
        options: Options(
          headers: {
            if (cookie != null) "Cookie": cookie,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception("Failed to change password.");
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
    final cookie = prefs.getString(_tokenKey);
    if (cookie != null && cookie.isNotEmpty) {
      // Return only the key=value pair (e.g. auth_token=...)
      // to avoid sending "Path=/" or "HttpOnly" back to the server
      return cookie.split(';').first.trim();
    }
    return null;
  }

  /// Returns `true` if the user has a saved auth cookie.
  Future<bool> isLoggedIn() async {
    if (_isLoggedInCached != null) return _isLoggedInCached!;
    final token = await getToken();
    _isLoggedInCached = token != null && token.isNotEmpty;
    return _isLoggedInCached!;
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
    
    // Clear static cache
    _profileCache = null;
    _isLoggedInCached = false;
  }
}
