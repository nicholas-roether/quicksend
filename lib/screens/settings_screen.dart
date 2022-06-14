import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/screens/settings/user_edit_screen.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:quicksend/widgets/custom_listttile.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/padding_text.dart';
import 'package:quicksend/widgets/profile_picture.dart';
import 'package:skeletons/skeletons.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  UserInfo? userInfo;
  String? registeredDevices = "...";
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    final quicksendClient = QuicksendClientProvider.get(context);
    quicksendClient.getRegisteredDevices().then((value) {
      if (!mounted) return;
      setState(() {
        registeredDevices = value.length.toString();
      });
    });
    _statusController.text = userInfo?.status ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final quicksendClient = QuicksendClientProvider.get(context);
    quicksendClient.getUserInfo().then((value) {
      if (!mounted) return;
      setState(() {
        userInfo = value;
      });
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Profile",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          userInfo != null
              ? ListTile(
                  title: Text(
                    userInfo!.getName(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text(
                    userInfo!.username,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 20,
                        ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserEditScreen(
                            userInfo: userInfo!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    splashRadius: 20,
                  ),
                  leading: Hero(
                    child: ProfilePicture(radius: 24, userInfo: userInfo!),
                    tag: "profile pic",
                    key: Key(userInfo!.username),
                  ),
                )
              : SkeletonListTile(
                  hasLeading: true,
                  hasSubtitle: true,
                  leadingStyle: SkeletonAvatarStyle(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
            child: Text(
              "Status message:",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: CustomTextFormField(
              hintInfo: "",
              labelInfo: "Status Message",
              obscure: false,
              autocorrect: false,
              maxLines: 1,
              minLines: 1,
              noPadding: true,
              submitCallback: (value) {},
              textController: _statusController,
              inputType: TextInputType.text,
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          PaddingText(text: "Security"),
          CustomListtile(
            title: "Manage devices",
            icon: Icons.devices,
            onTapCallback: () {
              Navigator.pushNamed(context, "/registered_devices");
            },
          ),
          const CustomListtile(title: "Change Password", icon: Icons.security),
          const SizedBox(
            height: 60,
          ),
          PaddingText(text: "Other"),
          CustomListtile(
            title: "About",
            icon: Icons.info,
            onTapCallback: () {},
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
            ),
            child: CustomButton(
              pressedCallback: () async {
                await quicksendClient.logOut();
                Navigator.popAndPushNamed(context, "/");
              },
              title: "Logout",
            ),
          ),
        ],
      ),
    );
  }
}
