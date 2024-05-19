import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // Importa OneSignal

import 'package:parking_hub/pages/AuthState.dart';
import 'package:parking_hub/pages/socket_services.dart';
import 'package:parking_hub/pages/welcome_screen.dart';
import 'package:parking_hub/pages/login_screen.dart';
import 'package:parking_hub/pages/home_screen.dart';
import 'package:parking_hub/pages/register_screen.dart';
import 'package:parking_hub/pages/forgot_password_screen.dart';
import 'package:parking_hub/pages/settings_screen.dart';
import 'package:parking_hub/pages/profile_screen.dart';
import 'package:parking_hub/pages/details_garage_screen.dart';
import 'package:parking_hub/pages/payment_methods.dart'; // Importa tu página de métodos de pago

void main() {
  // Inicializa OneSignal antes de ejecutar la aplicación
  WidgetsFlutterBinding.ensureInitialized();
  
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("516d4d9c-8073-4a15-8ee0-af8dd7304e9f");

  // Habilita las notificaciones push
  OneSignal.Notifications.requestPermission(true);

  runApp(const ParkingHubApp());
}

class ParkingHubApp extends StatelessWidget {
  const ParkingHubApp({Key? key}) : super(key: key);

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
