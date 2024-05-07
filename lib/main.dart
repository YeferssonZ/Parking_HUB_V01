import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // Importa OneSignal

import 'package:demo01/pages/AuthState.dart';
import 'package:demo01/pages/socket_services.dart';
import 'package:demo01/pages/welcome_screen.dart';
import 'package:demo01/pages/login_screen.dart';
import 'package:demo01/pages/home_screen.dart';
import 'package:demo01/pages/register_screen.dart';
import 'package:demo01/pages/forgot_password_screen.dart';
import 'package:demo01/pages/settings_screen.dart';
import 'package:demo01/pages/profile_screen.dart';
import 'package:demo01/pages/details_garage_screen.dart';
import 'package:demo01/pages/payment_methods.dart'; // Importa tu página de métodos de pago

void main() {
  // Inicializa OneSignal antes de ejecutar la aplicación
  WidgetsFlutterBinding.ensureInitialized();
  
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("d9f94d6b-d05c-4268-98af-7cd5c052fe9c");

  // Habilita las notificaciones push
  OneSignal.Notifications.requestPermission(true);

  runApp(const Demo01App());
}

class Demo01App extends StatelessWidget {
  const Demo01App({Key? key}) : super(key: key);

  get _hours => null; // Reemplaza con la lógica para obtener las horas

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
        ChangeNotifierProvider(
          create: (context) =>
              SocketService(serverUrl: 'https://test-2-slyp.onrender.com'),
        ),
      ],
      child: MaterialApp(
        title: 'PARKING HUB',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/register': (context) => const RegisterPage(),
          '/forgot_password': (context) => ForgotPasswordPage(),
          '/settings': (context) => SettingsPage(),
          '/profile': (context) => ProfilePage(),
          '/details_garage': (context) =>
              DetailsGaragePage(garageId: '', selectedHours: _hours, ofertaId: ''),
          '/payment-methods': (context) =>
              PayMethodsPage(selectedHours: _hours, ofertaId: ''),
        },
      ),
    );
  }
}
