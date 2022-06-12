import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({Key? key, this.radius = 20, required this.userInfo})
      : super(key: key);
  final double radius;
  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    ImageProvider profileimage = NetworkImage(userInfo.pfpUrl!);
    return GestureDetector(
      onTap: () {
        showImageViewer(context, profileimage);
      },
      child: CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage("assets/img/profile-pic.png"),
        foregroundImage: userInfo.pfpUrl != null ? profileimage : null,
      ),
    );
  }
}
