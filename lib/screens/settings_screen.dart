import 'package:flutter/material.dart';
import 'package:quicksend/screens/settings/user_edit_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
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
              backgroundColor: Colors.white,
              radius: 30,
            ),
          ),
          MaterialButton(
            onPressed: () {},
            color: Colors.red,
            child: const Text("Ausloggen"),
          )
        ],
      ),
    );
  }
}
