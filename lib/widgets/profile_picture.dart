import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({Key? key, this.radius = 20, required this.userInfo})
      : super(key: key);
  final double radius;
  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 2 * radius,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage("assets/img/profile-pic.png"),
        foregroundImage:
            userInfo.pfpUrl != null ? NetworkImage(userInfo.pfpUrl!) : null,
      ),
    );
  }
}
