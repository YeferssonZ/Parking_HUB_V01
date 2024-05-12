import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:demo01/pages/AuthState.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: ListView(
        children: [
          // Sección de información y decoración
          _buildSectionHeader('Información General'),
          ListTile(
            title: Text('Versión de la aplicación'),
            trailing: Text('1.0.0'),
          ),
          ListTile(
            title: Text('Última actualización'),
            trailing: Text('Hoy'),
          ),
          Divider(), // Línea divisoria decorativa

          // Sección de diseño y preferencias visuales
          _buildSectionHeader('Personalización'),
          ListTile(
            title: Text('Tema de la aplicación'),
            trailing: Text('Claro'),
          ),
          ListTile(
            title: Text('Tamaño del texto'),
            trailing: Text('Mediano'),
          ),
          Divider(), // Línea divisoria decorativa

          // Sección de contacto
          _buildSectionHeader('Contacto'),
          ListTile(
            title: Text('Soporte técnico'),
            trailing: Text('support@example.com'),
          ),
          ListTile(
            title: Text('Sitio web'),
            trailing: Text('www.parkinghub.com'),
          ),

          Divider(), // Línea divisoria decorativa

          // Sección de Eliminar cuenta
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
    // Obtener el token de autenticación del proveedor de estado
    String token = Provider.of<AuthState>(context, listen: false).token;

    // Decodificar el token para obtener el ID del usuario
    Map<String, dynamic> decodedToken = _decodeToken(token);
    String userId = decodedToken['id'];

    // Hacer la solicitud al endpoint de la API para eliminar la cuenta
    final url = Uri.parse('https://test-2-slyp.onrender.com/api/user/$userId');
    final response = await http.delete(
      url,
      headers: {'x-access-token': token},
    );

    if (response.statusCode == 200) {
      // La cuenta se eliminó correctamente, navegar a la pantalla de inicio de sesión
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      // Hubo un error al eliminar la cuenta, mostrar un mensaje de error
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
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
