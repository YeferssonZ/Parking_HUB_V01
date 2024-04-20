import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import "package:demo01/pages/AuthState.dart";
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final AnimationController _passwordVisibilityController;
  late final Animation<double> _passwordIconRotationAnimation;

  bool _isPasswordVisible = false;
  String? _token;

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

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        // Autenticación exitosa, puedes usar googleAuth.accessToken y googleAuth.idToken

        // Luego, puedes navegar a la página de inicio o realizar otras acciones.
        setState(() {
          _token = googleAuth.idToken;
        });
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      print('Error al iniciar sesión con Google: $error');
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final url =
        Uri.parse('https://parking-back-pt6g.onrender.com/api/auth/signin');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String token = responseData['token'];
        
        // Autenticación exitosa, puedes manejar la respuesta aquí
        Provider.of<AuthState>(context, listen: false).setToken(token);
        Navigator.pushReplacementNamed(context, '/home');
        
      } else {
        // Error en la autenticación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Credenciales incorrectas. Por favor, intenta de nuevo.'),
          ),
        );
      }
    } catch (error) {
      print('Error al iniciar sesión: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error al iniciar sesión. Por favor, intenta de nuevo.'),
        ),
      );
    }
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
                    height: 200.0,
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
                              textStyle: TextStyle(fontSize: 28.0),
                              duration: Duration(seconds: 4),
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
                    SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/forgot_password'),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _signInWithEmailAndPassword,
                      child: Text('Iniciar Sesión'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40.0),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: 24.0,
                        width: 24.0,
                      ),
                      label: Text('Iniciar con Google'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red,
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 40.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
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
