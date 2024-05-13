import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:parking_hub/pages/AuthState.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 153, 15, 40),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Información General'),
          _buildListTile('Versión de la aplicación', '1.0.0'),
          _buildListTile('Última actualización', 'Hoy'),
          Divider(),

          _buildSectionHeader('Personalización'),
          _buildListTile('Tema de la aplicación', 'Claro'),
          _buildListTile('Tamaño del texto', 'Mediano'),
          Divider(),

          _buildSectionHeader('Contacto'),
          _buildListTile('Soporte técnico', 'support@gmail.com'),
          _buildListTile('Sitio web', 'www.parkinghub.com'),
          Divider(),

          _buildSectionHeader('Cuenta'),
          ListTile(
            title: Text(
              'Eliminar Cuenta',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile(String title, String trailingText) {
    return ListTile(
      title: Text(title),
      trailing: Text(trailingText),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación de Cuenta'),
        content: Text('¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _deleteAccount(context),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    String token = Provider.of<AuthState>(context, listen: false).token;
    Map<String, dynamic> decodedToken = _decodeToken(token);
    String userId = decodedToken['id'];

    final url = Uri.parse('https://test-2-slyp.onrender.com/api/user/$userId');
    final response = await http.delete(
      url,
      headers: {'x-access-token': token},
    );

    if (response.statusCode == 200) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error al eliminar cuenta'),
          content: Text('Hubo un error al intentar eliminar tu cuenta. Por favor, inténtalo de nuevo más tarde.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
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
}
