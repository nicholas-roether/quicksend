import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/profile_picture.dart';

class UserEditScreen extends StatefulWidget {
  const UserEditScreen({Key? key, required this.userInfo}) : super(key: key);
  final UserInfo userInfo;

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _displayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _displayController.text = widget.userInfo.username;
    _statusController.text = widget.userInfo.status ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userInfo.username,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Hero(
                tag: "profile pic",
                child: ProfilePicture(
                  radius: 70,
                  userInfo: widget.userInfo,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Change status message",
                ),
              ),
              CustomTextFormField(
                hintInfo: "",
                labelInfo: "",
                obscure: false,
                textController: _statusController,
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Change display name",
                ),
              ),
              CustomTextFormField(
                hintInfo: "",
                labelInfo: "",
                obscure: false,
                textController: _displayController,
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Change password",
                ),
              ),
              CustomTextFormField(
                hintInfo: "",
                labelInfo: "",
                obscure: true,
                textController: _passwordController,
              ),
              CustomButton(
                pressedCallback: () async {
                  try {
                    final quicksendClient =
                        QuicksendClientProvider.get(context);
                    await quicksendClient.updateUser(
                        display: _displayController.text.isEmpty
                            ? _displayController.text
                            : null,
                        password: _passwordController.text.isEmpty
                            ? _passwordController.text
                            : null,
                        status: _statusController.text.isEmpty
                            ? _statusController.text
                            : null);
                  } catch (error) {
                    print(error.toString());
                  }
                },
                title: "Save changes",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
