import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:demo01/pages/AuthState.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    String token = Provider.of<AuthState>(context, listen: false).token;
    Map<String, dynamic> decodedToken = _decodeToken(token);
    String userId = decodedToken['id'];

    final url = Uri.parse('https://test-2-slyp.onrender.com/api/user/$userId');
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
      print('Error al obtener los datos del usuario: ${response.statusCode}');
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    List<String> parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[200],
              backgroundImage: NetworkImage('https://picsum.photos/200'),
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
            SizedBox(height: 20),
            Text(
              _name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(height: 10),
            Divider(
              color: Colors.grey[400],
              thickness: 1.5,
            ),
            SizedBox(height: 20),
            buildUserInfoRow('Usuario:', _username),
            buildUserInfoRow('Correo:', _email),
          ],
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
