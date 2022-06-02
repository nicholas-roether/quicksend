import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/screens/settings/user_edit_screen.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:skeletons/skeletons.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  UserInfo? userInfo;

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
        children: [
          const SizedBox(
            height: 50,
          ),
          userInfo != null
              ? ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserEditScreen(
                          username: userInfo!.getName(),
                        ),
                      ),
                    );
                  },
                  title: Text(userInfo!.getName(),
                      style: Theme.of(context).textTheme.headline6),
                  subtitle: Text(
                    "Status",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  leading: const CircleAvatar(
                    radius: 30,
                  ),
                )
              : SkeletonListTile(
                  hasLeading: true,
                  hasSubtitle: true,
                ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, "/registered_devices");
            },
            title: Text(
              "Account Settings",
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Text(
              "Currently Registered devices: ",
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            onTap: () {},
            title: Text(
              "About",
              style: Theme.of(context).textTheme.headline6,
            ),
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
