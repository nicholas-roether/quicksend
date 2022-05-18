import 'package:flutter/material.dart';
import 'package:quicksend/screens/settings/user_edit_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            title: Text(
              "Anzeigename",
              style: Theme.of(context).textTheme.headline6,
            ),
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
              "Benutzerverwaltung",
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Text(
              "Aktuell angemeldete Benutzer: ",
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
        ],
      ),
    );
  }
}
