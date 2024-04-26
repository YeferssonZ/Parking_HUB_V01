import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeInController;
  late final Animation<double> _fadeInAnimation;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeInAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeInController);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    _fadeInController.forward();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECE9FE), // Fondo lila claro
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeInAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150.0,
                  height: 150.0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '¡Bienvenido a PARKING HUB!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF7E57C2), // Texto en color lila oscuro
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Acabas de ahorrar una semana de desarrollo y dolores de cabeza.',
                  style: TextStyle(
                    color: Color(0xFF9575CD), // Texto en color lila medio
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Column(
                children: [
                  ScaleTransition(
                    scale: ReverseAnimation(_scaleAnimation),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xFF673AB7)), // Color de botón en lila oscuro
                        foregroundColor: MaterialStateProperty.all(Colors.white), // Color de texto blanco
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                    scale: _scaleAnimation,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xFFBA68C8)), // Color de botón en lila claro
                        foregroundColor: MaterialStateProperty.all(Colors.white), // Color de texto blanco
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
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
            ),
          ],
        ),
      ),
    );
  }
}