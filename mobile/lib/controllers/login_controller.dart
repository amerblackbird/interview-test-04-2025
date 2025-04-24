import 'package:get/get.dart';
import 'package:kmbal_movies_app/controllers/auth_controller.dart';
import 'package:kmbal_movies_app/models/api_response.dart';
import 'package:kmbal_movies_app/models/login_request.dart';
import 'package:kmbal_movies_app/models/login_response.dart';
import 'package:kmbal_movies_app/services/api_client.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find();
  final ApiClient _apiClient = Get.find();

  Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async {
    final response = await _apiClient.login(LoginRequest(
      email: email,
      password: password,
    ));

    if (response.kind == ApiResponseKind.ok) {
      _authController.setToken(response.data!.token);
      _authController.setUserId(response.data!.id);
      Get.offAllNamed("/movies");
    }

    return response;
  }
}
