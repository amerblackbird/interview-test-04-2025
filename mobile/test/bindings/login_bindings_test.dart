import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kmbal_movies_app/bindings/login_bindings.dart';
import 'package:kmbal_movies_app/controllers/auth_controller.dart';
import 'package:kmbal_movies_app/controllers/login_controller.dart';
import 'package:kmbal_movies_app/services/api_client.dart';

void main() {
  group('LoginBindings', () {
    setUp(() {
      // Clear any previous bindings to ensure a clean test environment
      Get.reset();
      Get.lazyPut(() => ApiClient());
      Get.lazyPut(() => AuthController());
    });

    test('dependencies should register LoginController using lazyPut', () {
      // Arrange
      final bindings = LoginBindings();

      // Act
      bindings.dependencies();

      // Assert
      expect(Get.isRegistered<LoginController>(), true);

      // Verify that the controller is lazily instantiated
      final controller = Get.find<LoginController>();
      expect(controller, isA<LoginController>());
    });
  });
}