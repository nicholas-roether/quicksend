import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';

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
        _usernameController.text,
        _passwordController.text,
      );

      Navigator.popAndPushNamed(context, "/");
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            mode == LoginMode.login ? "Login" : "Register",
            style: Theme.of(context).textTheme.headlineSmall,
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
                          "assets/img/icon_transparent.png",
                          height: 200,
                        ),
                        Text(
                          mode == LoginMode.login
                              ? "Welcome back!"
                              : "Welcome to Quicksend!",
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        CustomTextFormField(
                          maxLines: 1,
                          minLines: 1,
                          hintInfo: "Enter a Username",
                          labelInfo: "Username",
                          obscure: false,
                          autocorrect: false,
                          textController: _usernameController,
                        ),
                        CustomTextFormField(
                          hintInfo: "Enter a password",
                          labelInfo: "Password",
                          obscure: true,
                          autocorrect: false,
                          inputType: TextInputType.visiblePassword,
                          textController: _passwordController,
                        ),
                        mode == LoginMode.register
                            ? CustomTextFormField(
                                minLines: 1,
                                maxLines: 1,
                                hintInfo: "Enter a Display Name",
                                labelInfo: "Display Name",
                                obscure: false,
                                autocorrect: false,
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
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              )
            : LoadingIndicator(),
      ),
    );
  }
}
