import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmbal_movies_app/controllers/login_controller.dart';
import 'package:kmbal_movies_app/models/api_response.dart';
import 'package:kmbal_movies_app/models/login_response.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();

    Future<ApiResponse<LoginResponse>> onLogin(String email, String password) {
      return loginController.login(email, password);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Image(
                  image: AssetImage('assets/logo.png'),
                  height: 30,
                ),
                Text(
                  "Movie Reviews",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 16),
                LoginForm(
                  onLogin: onLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final Future<ApiResponse<LoginResponse>> Function(
      String email, String password) onLogin;

  const LoginForm({super.key, required this.onLogin});

  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  var _disabled = false;
  String? _apiError;

  final _formKey = GlobalKey<FormState>();

  final _emailFocusNode = FocusNode();
  final _emailTextController = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _passwordTextController = TextEditingController();

  void _clearApiError() {
    if (_apiError != null) {
      setState(() => _apiError = null);
    }
  }

  void _submit() async {
    _clearApiError();
    if (_formKey.currentState!.validate()) {
      setState(() => _disabled = true);
      var controller = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging in...')),
      );
      try {
        final response = await widget.onLogin(
          _emailTextController.text,
          _passwordTextController.text,
        );

        if (response.kind == ApiResponseKind.unknownError) {
          _apiError = "Unknown error. Please try again.";
        }
        else if (response.kind == ApiResponseKind.validationError) {
          _apiError = response.validationError!.message;
        }
        setState(() {});
      } finally {
        controller.close();
        setState(() => _disabled = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if(kDebugMode) {
      _emailTextController.text = "testing1@gmail.com";
      _passwordTextController.text = "Testing1";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            enabled: !_disabled,
            focusNode: _emailFocusNode,
            controller: _emailTextController,
            onTapOutside: (_) => _emailFocusNode.unfocus(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text(
                "Email",
              ),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            enabled: !_disabled,
            focusNode: _passwordFocusNode,
            controller: _passwordTextController,
            onTapOutside: (_) => _passwordFocusNode.unfocus(),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text(
                "Password",
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_apiError != null) ...[
            Text(_apiError!),
            SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _disabled ? null : _submit,
            child: Text(
              "Login",
            ),
          ),
        ],
      ),
    );
  }
}
