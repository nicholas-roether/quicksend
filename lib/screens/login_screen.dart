import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../widgets/custom_text_form_field.dart';
import '../widgets/loading_indicator.dart';

enum LoginMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displaynameController = TextEditingController();
  LoginMode mode = LoginMode.register;
  bool _isLoading = false;
  final bool _isFirstFrame = true;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => CustomErrorWidget(message: message),
    );
  }

  void _submit() async {
    final quicksendClient = QuicksendClientProvider.get(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }
    var uuid = const Uuid();
    setState(() {
      _isLoading = true;
    });
    try {
      if (mode == LoginMode.register) {
        await quicksendClient.createAccount(
          _usernameController.text,
          _passwordController.text,
          _displaynameController.text,
        );
      }
      await quicksendClient.logIn(
        uuid.v1().substring(0, 15),
        _usernameController.text,
        _passwordController.text,
      );

      Navigator.popAndPushNamed(context, "/home");
    } on RequestException catch (error) {
      var errorMessage = "login attempt failed!";
      if (error.status == 401) {
        errorMessage = "Username or password is incorrect!";
      } else {
        errorMessage = error.message;
      }
      _showErrorDialog(errorMessage);
    } on UnknownUserException {
      _showErrorDialog("User does not exist!");
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    final quicksendClient = QuicksendClientProvider.get(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (quicksendClient.isLoggedIn()) {
        Navigator.popAndPushNamed(context, "/home");
      }
      FlutterNativeSplash.remove();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == LoginMode.login ? "Login" : "Register",
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: !_isLoading
          ? SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/img/icon-transparent.png",
                        height: 200,
                      ),
                      Text(
                        mode == LoginMode.login
                            ? "Welcome back!"
                            : "Welcome to Quicksend!",
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50),
                      CustomTextFormField(
                        hintInfo: "Enter a Username",
                        labelInfo: "Username",
                        obscure: false,
                        textController: _usernameController,
                      ),
                      CustomTextFormField(
                        hintInfo: "Enter a password",
                        labelInfo: "Password",
                        obscure: true,
                        textController: _passwordController,
                      ),
                      mode == LoginMode.register
                          ? CustomTextFormField(
                              hintInfo: "Enter a Display Name",
                              labelInfo: "Display Name",
                              obscure: false,
                              textController: _displaynameController,
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: TextButton(
                          onPressed: () {
                            if (mode == LoginMode.login) {
                              setState(() {
                                mode = LoginMode.register;
                              });
                            } else {
                              setState(() {
                                mode = LoginMode.login;
                              });
                            }
                          },
                          child: Text(mode == LoginMode.login
                              ? "New here? Create an account"
                              : "Already registered? Click to login"),
                        ),
                      ),
                      CustomButton(
                        pressedCallback: _submit,
                        title: mode == LoginMode.login ? "Login" : "Register",
                      ),
                    ],
                  ),
                ),
              ),
            )
          : LoadingIndicator(),
    );
  }
}
