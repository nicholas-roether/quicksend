import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/widgets/profile_picture.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key, required this.userInfo}) : super(key: key);
  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(userInfo.getName())),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            ProfilePicture(
              radius: 70,
              userInfo: userInfo,
            ),
          ],
        ),
      ),
    );
  }
}
