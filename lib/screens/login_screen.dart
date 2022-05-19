import 'package:flutter/material.dart';

import '../widgets/custom_text_form_field.dart';

enum LoginMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

///TODO
/// Add Animation to register Screen
/// TextEditingController [TextEditingController]
/// submitting Data in Form
/// create Login/register Button
/// change Color of the Text
///

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  LoginMode mode = LoginMode.login;

  void _submit() {
    //todo: implement submitting the Form
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomTextFormField(
                hintInfo: "Enter a Username",
                labelInfo: "Username",
              ),
              const CustomTextFormField(
                hintInfo: "Enter a password",
                labelInfo: "Password",
              ),
              mode == LoginMode.register
                  ? const CustomTextFormField(
                      hintInfo: "Enter a Display Name",
                      labelInfo: "Display Name")
                  : const SizedBox(
                      height: 0,
                    ),
              TextButton(
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
                    ? "new here? create Account"
                    : "Already registered? click to login"),
              ),
              MaterialButton(
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
