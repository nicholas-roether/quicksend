import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({Key? key, this.radius = 20, required this.userInfo})
      : super(key: key);
  final double radius;
  final UserInfo userInfo;

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  String? assetUrl;

  @override
  void initState() {
    assetUrl = widget.userInfo.pfpUrl;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    assetUrl = widget.userInfo.pfpUrl;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundImage: const AssetImage("assets/img/profile-pic.png"),
      foregroundImage: assetUrl != null ? NetworkImage(assetUrl!) : null,
    );
  }
}
