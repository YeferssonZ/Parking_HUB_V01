import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:parking_hub/pages/AuthState.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTermsAndConditions = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register(BuildContext context) async {
    final url = Uri.parse('https://test-2-slyp.onrender.com/api/auth/signup');

    try {
      final response = await http.post(
        url,
        body: {
          'name': _nameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String token = responseData['token'];

        Provider.of<AuthState>(context, listen: false).setToken(token);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registro exitoso'),
              content: Text('Usuario registrado correctamente.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  void _handleLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 239, 143, 162),
              Color.fromARGB(255, 153, 15, 40)
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.0),
                Text(
                  '¡Bienvenido PARKERO!\nRegístrate',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Por favor, ingresa tu nombre';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Por favor, ingresa un nombre de usuario';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Por favor, ingresa tu correo electrónico';
                              }
                              if (!value.contains('@')) {
                                return 'Ingresa un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                child: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Por favor, ingresa una contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Contraseña',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                                child: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Por favor, confirma tu contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptedTermsAndConditions,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTermsAndConditions = value!;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'Acepto los términos y condiciones',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TermsAndConditionsScreen(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.description_outlined),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate() &&
                                  _acceptedTermsAndConditions) {
                                _register(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Por favor, completa todos los campos y acepta los términos y condiciones',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('Registrarse',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Color.fromARGB(255, 153, 15, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('¿Ya tienes una cuenta?'),
                              TextButton(
                                onPressed: _handleLogin,
                                child: Text('Inicia sesión aquí'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Términos y condiciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 153, 15, 40),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: WebView(
        initialUrl: 'https://terminos-condiciones-nine.vercel.app/',
        javascriptMode: JavascriptMode.unrestricted,
        onProgress: (int progress) {},
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        navigationDelegate: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
