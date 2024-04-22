import 'package:demo01/pages/profile_screen.dart';
import 'package:demo01/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:demo01/pages/home_screen.dart';
import 'package:demo01/pages/login_screen.dart';
import 'package:demo01/pages/register_screen.dart';
import 'package:demo01/pages/forgot_password_screen.dart';
import 'package:provider/provider.dart';
import "package:demo01/pages/AuthState.dart";

void main() {
  runApp(const Demo01App());
}

class Demo01App extends StatelessWidget {
  const Demo01App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthState(),
      child: MaterialApp(
        title: 'PARKING HUB',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/register': (context) => const RegisterPage(),
          '/forgot_password': (context) => ForgotPasswordPage(),
          '/settings': (context) => SettingsScreen(),
          '/profile': (context) => ProfileScreen(),
        },
      ),
    );
  }
}
