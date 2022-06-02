import 'package:flutter/material.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';

class UserEditScreen extends StatefulWidget {
  const UserEditScreen({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _displayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _displayController.text = widget.username;
    _statusController.text = "Hier kommt später die Status message hin";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.username,
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
              const Hero(
                tag: "profile pic",
                child: CircleAvatar(
                  radius: 70,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              CustomTextFormField(
                hintInfo: "",
                labelInfo: "Status message",
                obscure: false,
                textController: _statusController,
              ),
              CustomTextFormField(
                hintInfo: "",
                labelInfo: "Change display name",
                obscure: false,
                textController: _displayController,
              ),
              CustomTextFormField(
                hintInfo: "",
                labelInfo: "Change password",
                obscure: true,
                textController: _passwordController,
              ),
              CustomButton(
                pressedCallback: () {},
                title: "Save changes",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
