import 'package:flutter/material.dart';

class RegisteredDevices extends StatelessWidget {
  const RegisteredDevices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registered devices",
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      /*body: AnimatedBuilder(
				animation: ,
        builder: (context, _) {
					return ListView.builder(itemBuilder: () {}, itemCount: 3,);
				},
      ),*/
    );
  }
}
