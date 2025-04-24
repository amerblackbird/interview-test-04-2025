import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmbal_movies_app/bindings/login_bindings.dart';
import 'package:kmbal_movies_app/bindings/movies_bindings.dart';
import 'package:kmbal_movies_app/controllers/auth_controller.dart';
import 'package:kmbal_movies_app/middleware/auth_middleware.dart';
import 'package:kmbal_movies_app/pages/home.dart';
import 'package:kmbal_movies_app/pages/login.dart';
import 'package:kmbal_movies_app/pages/movies/index.dart';
import 'package:kmbal_movies_app/pages/movies/show.dart';
import 'package:kmbal_movies_app/services/api_client.dart';
import 'package:kmbal_movies_app/tokens.dart';

import 'pages/movies/submit_view.dart';

void main() {
  Get.put(AuthController(), permanent: true);
  Get.put(ApiClient(), permanent: true);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorTokens.brand,
          brightness: Brightness.light,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((state) {
              if (state.contains(WidgetState.disabled)) {
                return ColorTokens.lightBlue900;
              }
              return ColorTokens.darkBlue100;
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ),
      getPages: [
        GetPage(name: "/", page: () => const HomePage()),
        GetPage(
          name: "/login",
          page: () => const LoginPage(),
          bindings: [LoginBindings()],
        ),
        GetPage(
          name: "/movies",
          page: () => const MoviesPage(),
          middlewares: [AuthMiddleware()],
          bindings: [MoviesBindings()],
        ),
        GetPage(
          name: "/movies/show",
          page: () => const ShowMoviePage(),
          middlewares: [AuthMiddleware()],
          bindings: [MoviesBindings()],
        ),
        GetPage(
          name: "/movies/show/review",
          page: () => const SubmitViewPage(),
          middlewares: [AuthMiddleware()],
          bindings: [MoviesBindings()],
        ),
      ],
    );
  }
}
