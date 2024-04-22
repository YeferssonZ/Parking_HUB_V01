import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:demo01/pages/AuthState.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AnimationController _fadeInController;
  late final Animation<double> _fadeInAnimation;
  late final AnimationController _slideInController;
  late final Animation<Offset> _slideInAnimation;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptedTermsAndConditions = false;

  Future<void> _register(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.102:3000/api/auth/signup');

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
              content: Text('Se ha creado el token correctamente.'),
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

  @override
  void initState() {
    super.initState();

    _fadeInController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeInController);

    _slideInController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _slideInAnimation = Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero)
        .animate(_slideInController);

    _fadeInController.forward();
    _slideInController.forward();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _slideInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regístrate'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade200],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideInAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 200.0,
                      child: _buildAnimatedDecoration(),
                    ),
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
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'El nombre es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre de usuario',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'El nombre de usuario es obligatorio';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                                    return 'El nombre de usuario solo puede contener letras y números';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
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
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Ingresa un correo electrónico válido';
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
                                obscureText: !_isPasswordVisible,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'La contraseña es obligatoria';
                                  }
                                  if (!RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$')
                                      .hasMatch(value)) {
                                    return 'La contraseña debe contener al menos una mayúscula, un número y tener al menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirmar contraseña',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
                                    child: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                  ),
                                ),
                                obscureText: !_isConfirmPasswordVisible,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Confirma tu contraseña';
                                  }
                                  if (_passwordController.text !=
                                      _confirmPasswordController.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.0),
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
                                    child: IgnorePointer(
                                      ignoring: true,
                                      child: Text(
                                        'Acepto los términos y condiciones',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TermsAndConditionsScreen(),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.info_outline),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      _acceptedTermsAndConditions) {
                                    _register(context);
                                  } else if (!_acceptedTermsAndConditions) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Debes aceptar los términos y condiciones para continuar',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text('Registrarse'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 40.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('¿Ya tienes cuenta?'),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Iniciar Sesión'),
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
        ),
      ),
    );
  }

  Widget _buildAnimatedDecoration() {
    return AnimatedContainer(
      duration: Duration(seconds: 3),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(0.0, -10.0, 0.0),
      child: Placeholder(
        color: Colors.white,
      ),
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Términos y condiciones'),
      ),
      body: WebView(
        initialUrl: 'https://darktermsandconditions.netlify.app/privacy.html',
        javascriptMode: JavascriptMode.unrestricted,
        onProgress: (int progress) {
          // Here you can handle the page loading progress if needed.
        },
        onPageStarted: (String url) {
          // Called when the web page starts loading.
        },
        onPageFinished: (String url) {
          // Called when the web page has finished loading.
        },
        onWebResourceError: (WebResourceError error) {
          // Called if an error occurs while loading the web page.
        },
        navigationDelegate: (NavigationRequest request) {
          // You can customize how to handle navigation requests.
          // For example, to prevent navigation to certain URLs.
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
