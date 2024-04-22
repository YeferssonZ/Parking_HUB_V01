import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:demo01/pages/AuthState.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Obtener el token del proveedor de estado de autenticación
    String token = Provider.of<AuthState>(context, listen: false).token;

    // Decodificar el token para obtener el ID del usuario
    Map<String, dynamic> decodedToken = _decodeToken(token);
    String userId = decodedToken['id'];

    // Hacer la solicitud al endpoint de la API para obtener los detalles del usuario
    final url = Uri.parse('http://192.168.1.102:3000/api/user/$userId');
    final response = await http.get(
      url,
      headers: {'x-access-token': token},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> userData = jsonDecode(response.body);
      setState(() {
        _name = userData['name'];
        _username = userData['username'];
        _email = userData['email'];
      });
    } else {
      // Manejar el error de la solicitud
      print('Error al obtener los datos del usuario: ${response.statusCode}');
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    // Dividir el token en sus partes (header, payload, signature)
    List<String> parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }

    // Decodificar la parte del payload (contenido del token)
    String payload = _decodeBase64(parts[1]);
    return jsonDecode(payload);
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Token inválido');
    }
    return utf8.decode(base64Url.decode(output));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parking Hub - Perfil',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _name.isNotEmpty ? 1 : 0,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('Profile picture tapped');
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue[200],
                        backgroundImage:
                            NetworkImage('https://picsum.photos/200'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: AnimatedOpacity(
                            opacity: 1,
                            duration: Duration(milliseconds: 300),
                            child: Text(
                              _name.isNotEmpty ? _name[0].toUpperCase() : '',
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 100,
                          height: 2,
                          color: Colors.blue[900],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Divider(
                color: Colors.grey[400],
                thickness: 1.5,
              ),
              SizedBox(height: 20),
              buildUserInfoRow('Usuario:', _username),
              buildUserInfoRow('Correo:', _email),
              SizedBox(height: 40),
              Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    gradient: LinearGradient(
                      colors: [Colors.teal[700]!, Colors.blue[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      print('Editar perfil button pressed');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Editar perfil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserInfoRow(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue[700],
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 15),
        Container(
          width: 120,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[700]!, Colors.blue[900]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 25),
      ],
    );
  }
}
