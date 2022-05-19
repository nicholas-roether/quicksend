import 'package:flutter/material.dart';

enum LoginMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  LoginMode mode = LoginMode.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Login",
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
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
                    border: InputBorder.none,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
