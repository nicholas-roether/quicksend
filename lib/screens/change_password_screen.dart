import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/client/provider.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/profile_picture.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key, this.userInfo}) : super(key: key);
  final UserInfo? userInfo;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Change Password",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Center(
                child: Hero(
                  transitionOnUserGestures: true,
                  tag: "profile pic",
                  child: ProfilePicture(
                    radius: 70,
                    userInfo: widget.userInfo!,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  "Account name:",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.userInfo!.username,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "Current password:",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              CustomTextFormField(
                hintInfo: "",
                labelInfo: "",
                obscure: true,
                textController: _passwordController,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "New password:",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              CustomTextFormField(
                hintInfo: "",
                labelInfo: "",
                obscure: true,
                textController: _newPasswordController,
              ),
              CustomButton(
                pressedCallback: () async {
                  if (_passwordController.text.isEmpty ||
                      _newPasswordController.text.isEmpty) return;
                  try {
                    final quicksendClient =
                        QuicksendClientProvider.get(context);
                    await quicksendClient.updatePassword(
                        _passwordController.text, _newPasswordController.text);
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(5),
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            "Edited user information",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.black,
                                    ),
                          ),
                        ),
                      ),
                    );
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomErrorWidget(
                          message: error.toString(),
                        );
                      },
                    );
                  }
                },
                title: "Change password",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
