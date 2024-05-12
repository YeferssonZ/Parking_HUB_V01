import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Duración total de la animación
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/images/logo.png',
                width: 150.0,
                height: 150.0,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '¡Bienvenido a PARKING HUB!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.deepPurple, // Texto en color lila oscuro
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto', // Tipo de letra profesional
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Encuentra el lugar perfecto para estacionar de manera fácil y segura con PARKING HUB.',
                style: TextStyle(
                  color: Colors.purpleAccent, // Texto en color lila medio
                  fontSize: 18,
                  fontFamily: 'Roboto', // Tipo de letra profesional
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.deepPurple), // Color de botón en lila oscuro
                      foregroundColor: MaterialStateProperty.all(Colors.white), // Color de texto blanco
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto', // Tipo de letra profesional
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                ),
                const SizedBox(height: 16),
                ScaleTransition(
                  scale: _animation,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.purpleAccent), // Color de botón en lila claro
                      foregroundColor: MaterialStateProperty.all(Colors.white), // Color de texto blanco
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto', // Tipo de letra profesional
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
