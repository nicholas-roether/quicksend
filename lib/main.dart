import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/screens/homepage.dart';
import 'package:quicksend/screens/login_screen.dart';
import 'package:quicksend/screens/settings/registered_devices_screen.dart';
import 'package:quicksend/utils/my_themes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final quicksendClient = QuicksendClient();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await quicksendClient.init();
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuicksendClientProvider(
      client: quicksendClient,
      child: SafeArea(
        child: MaterialApp(
          title: 'Quicksend',
          debugShowCheckedModeBanner: false,
          theme: MyThemes.mainTheme,
          routes: {
            "/": (context) {
              final quicksendClient = QuicksendClientProvider.get(context);
              return quicksendClient.isLoggedIn()
                  ? const HomePage()
                  : const LoginScreen();
            },
            "/registered_devices": (context) => const RegisteredDevices(),
          },
        ),
      ),
    );
  }
}
