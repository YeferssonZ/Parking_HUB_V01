import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi perfil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar and name
              Row(
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.blueGrey[200],
                    child: Text(
                      'U',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    'Usuario',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),

              // Email and phone number
              Text(
                'Correo electrónico: usuario@correo.com',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Número de teléfono: +51 999 999 999',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),

              // Settings button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the settings screen
                  Navigator.pushNamed(context, '/settings');
                },
                child: Text('Configuración'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

