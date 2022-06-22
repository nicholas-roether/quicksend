import 'package:flutter/material.dart';

class CustomListtile extends StatelessWidget {
  const CustomListtile(
      {Key? key,
      required this.title,
      this.subtitle,
      this.icon,
      this.iconColor,
      this.trailingIcon,
      this.onTapCallback})
      : super(key: key);
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final IconData? trailingIcon;
  final void Function()? onTapCallback;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTapCallback,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading: Icon(
        icon,
        size: Theme.of(context).iconTheme.size,
      ),
      trailing: trailingIcon != null
          ? Icon(
              trailingIcon,
              color: iconColor,
            )
          : null,
    );
  }
}
