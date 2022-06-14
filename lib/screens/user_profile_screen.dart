import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/widgets/profile_picture.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userInfo = ModalRoute.of(context)!.settings.arguments as UserInfo;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          userInfo.getName(),
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
                child: ProfilePicture(
                  radius: 70,
                  userInfo: userInfo,
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
                  userInfo.username,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  userInfo.getName(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Status message:",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  userInfo.status ?? "",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
