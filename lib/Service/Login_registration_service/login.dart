import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:suggestion_sharing_platform/App_Constance/app_cons.dart';
import 'package:suggestion_sharing_platform/Models/Login_Registration/login_request.dart';

class LoginService {
  final Dio _dio = Dio();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppCons.loginapi,
        data: LoginRequest(
          email: email,
          password: password,
        ).toJson(),
      );

      if (kDebugMode) {
        print("Login success: ${response.data}");
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print("Login error: ${e.response?.data}");
      }
    }
  }
}
