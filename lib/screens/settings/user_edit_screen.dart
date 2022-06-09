import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/image_source_dialog.dart';
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
    _displayController.text = widget.userInfo.getName();
    _statusController.text = widget.userInfo.status ?? "";
    _passwordController.text = "";
    super.initState();
  }

  void _setProfilePicture(ImageSource source) async {
    final quicksendClient = QuicksendClientProvider.get(context);
    File? pickedImage;
    final _picker = ImagePicker();
    try {
      final image = await _picker.pickImage(source: source);
      if (image == null) return;

      pickedImage = File(image.path);
      await quicksendClient.setUserPfp(
          mime(pickedImage.path)!, pickedImage.readAsBytesSync());
    } on PlatformException catch (_) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomErrorWidget(message: "Could not send image!");
        },
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userInfo.getName(),
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Hero(
                tag: "profile pic",
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ImageSourceDialog(
                            iconButtonCallback: _setProfilePicture);
                      },
                    );
                  },
                  child: ProfilePicture(
                    radius: 70,
                    userInfo: widget.userInfo,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Tap to edit profile picture",
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
                minLines: 1,
                maxLines: 1,
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
                maxLines: 1,
                minLines: 1,
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
                minLines: 1,
                maxLines: 1,
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
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).primaryColor,
                          margin: const EdgeInsets.all(5),
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            "Edited user information",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                ?.copyWith(color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomErrorWidget(message: error.toString());
                      },
                    );
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
