import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:parking_hub/pages/AuthState.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '909305615965-vbudu35p67igircqprde46rjjr7uc4ot.apps.googleusercontent.com',
  );

  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final AnimationController _passwordVisibilityController;
  late final Animation<double> _passwordIconRotationAnimation;

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _passwordVisibilityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _passwordIconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(_passwordVisibilityController);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordVisibilityController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    final url = Uri.parse('https://test-2-slyp.onrender.com/api/auth/signin');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String token = responseData['token'];

        Provider.of<AuthState>(context, listen: false).setToken(token);
        // showDialog<void>(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text('Inicio de sesión correcto'),
        //       content: Text('¡Bienvenido!'),
        //       actions: <Widget>[
        //         TextButton(
        //           child: Text('Aceptar'),
        //           onPressed: () {
        //             Navigator.pushReplacementNamed(context, '/home');
        //           },
        //         ),
        //       ],
        //     );
        //   },
        // );
        Navigator.pushReplacementNamed(context, '/home');
      } else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        String message = responseData['message'];

        if (message == 'Correo no registrado') {
          _showErrorSnackbar(
            'Correo no registrado. ¿Deseas registrarte?',
            _handleRegister,
          );
        } else if (message == 'Contraseña incorrecta') {
          _showErrorSnackbar(
              'Contraseña incorrecta. Por favor, intenta de nuevo.');
        } else {
          _showErrorSnackbar('Error en la autenticación: $message');
        }
      } else {
        _showErrorSnackbar(
            'Error en la autenticación. Por favor, intenta de nuevo.');
      }
    } catch (error) {
      print('Error al iniciar sesión: $error');
      _showErrorSnackbar(
          'Error al iniciar sesión. Por favor, intenta de nuevo.');
    }
  }

  void _showErrorSnackbar(String message, [VoidCallback? action]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action != null
            ? SnackBarAction(
                label: 'Aceptar',
                onPressed: action,
              )
            : null,
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      print(
          'Intentando cerrar sesión en Google si hay alguna sesión activa...');
      await _googleSignIn.signOut();

      print('Intentando iniciar sesión con Google...');
      final account = await _googleSignIn.signIn();

      if (account != null) {
        print('Inicio de sesión con Google exitoso. Usuario: ${account.email}');
        final response = await http.post(
          Uri.parse('https://test-2-slyp.onrender.com/api/auth/check'),
          body: {'email': account.email},
        );

        if (response.statusCode == 200) {
          print('Usuario encontrado en la API.');
          final responseData = jsonDecode(response.body);
          String token = responseData['token'];
          Provider.of<AuthState>(context, listen: false).setToken(token);
          print('Token recibido: $token');
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Inicio de sesión correcto'),
                content: Text('¡Bienvenido!'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Aceptar'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ],
              );
            },
          );
        } else if (response.statusCode == 404) {
          print(
              'Usuario no encontrado en la API. Intentando registrar un nuevo usuario...');

          String generateRandomPassword({int length = 10}) {
            const _chars =
                'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.';
            final random = Random();
            return List.generate(
                    length, (index) => _chars[random.nextInt(_chars.length)])
                .join();
          }

          final signupResponse = await http.post(
            Uri.parse('https://test-2-slyp.onrender.com/api/auth/signup'),
            body: {
              'name': account.displayName,
              'username': account.email.split('@')[0],
              'email': account.email,
              'password': generateRandomPassword(),
            },
          );

          if (signupResponse.statusCode == 200) {
            print('Registro de nuevo usuario exitoso.');
            final responseData = jsonDecode(signupResponse.body);
            String token = responseData['token'];
            Provider.of<AuthState>(context, listen: false).setToken(token);
            print('Token recibido después del registro: $token');
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Inicio de sesión correcto'),
                  content: Text('¡Bienvenido!'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Aceptar'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            print(
                'Error en la solicitud a la API para registro: ${signupResponse.statusCode}');
            print('Respuesta del servidor: ${signupResponse.body}');
          }
        } else {
          print(
              'Error en la solicitud a la API para verificar el usuario: ${response.statusCode}');
          print('Respuesta del servidor: ${response.body}');
        }
      } else {
        print('Fallo el inicio de sesión con Google: cuenta es nula.');
      }
    } catch (error) {
      print('Error al iniciar sesión con Google: $error');
    }
  }

  void _handleRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/parking_app_background.jpg',
                    fit: BoxFit.cover,
                    height: 250.0,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 40.0,
                    left: 20.0,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80.0,
                      width: 80.0,
                    ),
                  ),
                  Positioned(
                    top: 120.0,
                    left: 20.0,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            RotateAnimatedText(
                              'PARKING HUB',
                              textStyle: TextStyle(fontSize: 48.0),
                              duration: Duration(seconds: 10),
                            ),
                          ],
                          onTap: () {
                            print("Tapped on the title");
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'El correo electrónico es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _passwordVisibilityController.forward();
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          child: AnimatedBuilder(
                            animation: _passwordVisibilityController,
                            builder: (context, child) {
                              return RotationTransition(
                                turns: _passwordIconRotationAnimation,
                                child: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'La contraseña es obligatoria';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _signInWithEmailAndPassword,
                      child: Text('Iniciar Sesión'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40.0),
                      ),
                    ),
                    // SizedBox(height: 10.0),
                    // ElevatedButton.icon(
                    //   onPressed: _signInWithGoogle,
                    //   icon: Image.asset(
                    //     'assets/images/google.png',
                    //     height: 24.0,
                    //     width: 24.0,
                    //   ),
                    //   label: Text('Iniciar con Google'),
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor: Colors.red,
                    //     backgroundColor: Colors.white,
                    //     minimumSize: Size(double.infinity, 40.0),
                    //   ),
                    // ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: _handleRegister,
                          child: Text('Regístrate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
