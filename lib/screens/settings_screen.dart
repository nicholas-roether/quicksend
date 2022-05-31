import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/screens/settings/user_edit_screen.dart';
import 'package:quicksend/widgets/custom_button.dart';
import 'package:quicksend/widgets/loading_indicator.dart';

// TODO add Skeleton UserEditScreen

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quicksendClient = QuicksendClientProvider.get(context);
    final Future<UserInfo> userInfo = quicksendClient.getUserInfo();

    return FutureBuilder<UserInfo>(
      future: userInfo,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingIndicator();
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserEditScreen(),
                    ),
                  );
                },
                title: Text(snapshot.data!.getName(),
                    style: Theme.of(context).textTheme.headline6),
                subtitle: Text(
                  "Status",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                leading: const CircleAvatar(
                  radius: 30,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                onTap: () {},
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
      },
    );
  }
}
