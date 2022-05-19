import 'package:flutter/material.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 100,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  mode == LoginMode.login ? "Login" : "Register",
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Enter a Username",
                  labelText: "Username",
                ),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter some textahh";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Enter a Password",
                  labelText: "Password",
                ),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter some textahh";
                  }
                  return null;
                },
              ),
              mode == LoginMode.register
                  ? TextFormField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter a display Name",
                          labelText: "Display Name"),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return "Please enter some textahh";
                        }
                        return null;
                      },
                    )
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
