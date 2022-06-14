import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:path/path.dart' as path;
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

  void _setProfilePictureWeb() async {
    final quicksendClient = QuicksendClientProvider.get(context);
    try {
      final imageInfo = await ImagePickerWeb.getImageInfo;
      if (imageInfo == null) return;
      await quicksendClient.setUserPfp(
          mime(path.basename(imageInfo.fileName!))!, imageInfo.data!);
      setState(() {});
    } on PlatformException catch (_) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomErrorWidget(message: "Could not send image!");
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Edit Profile",
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
                child: Column(
                  children: [
                    Hero(
                      transitionOnUserGestures: true,
                      tag: "profile pic",
                      child: GestureDetector(
                        onTap: () {
                          if (kIsWeb) {
                            _setProfilePictureWeb();
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ImageSourceDialog(
                                    iconButtonCallback: _setProfilePicture);
                              },
                            );
                          }
                        },
                        child: ProfilePicture(
                          radius: 70,
                          userInfo: widget.userInfo,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Tap to change",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "Account name:",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.userInfo.username,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Display name:",
                  style: Theme.of(context).textTheme.titleSmall,
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
              CustomButton(
                pressedCallback: () async {
                  /*try {
                    final quicksendClient =
                        QuicksendClientProvider.get(context);
                    await quicksendClient.updateUser(
                        display: _displayController.text.isEmpty
                            ? _displayController.text
                            : null,
                        // FIXME this option no longer exists.
                        // password: _passwordController.text.isEmpty
                        //     ? _passwordController.text
                        //     : null,
                        status: _statusController.text.isEmpty
                            ? _statusController.text
                            : null);
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          margin: EdgeInsets.all(5),
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            "Edited user information",
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
                  }*/
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
