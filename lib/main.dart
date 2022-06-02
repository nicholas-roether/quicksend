import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/screens/homepage.dart';
import 'package:quicksend/screens/login_screen.dart';
import 'package:quicksend/screens/settings/registered_devices_screen.dart';
import 'package:quicksend/utils/my_themes.dart';

final quicksendClient = QuicksendClient();

void main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  await quicksendClient.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuicksendClientProvider(
      client: quicksendClient,
      child: MaterialApp(
        title: 'Quicksend',
        debugShowCheckedModeBanner: false,
        theme: MyThemes.mainTheme,
        routes: {
          "/": (context) => const LoginScreen(),
          "/home": (context) => const HomePage(),
          "/registered_devices": (context) => const RegisteredDevices(),
        },
      ),
    );
  }
}
