import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:demo01/pages/AuthState.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  bool _useDarkTheme = false;
  String _selectedLanguage = 'Español';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: ListView(
        children: [
          // Sección de notificaciones
          _buildSectionHeader('Notificaciones'),
          SwitchListTile(
            title: Text('Recibir notificaciones de viajes'),
            value: _enableNotifications,
            onChanged: (value) => setState(() => _enableNotifications = value),
          ),
          ListTile(
            title: Text('Sonido de notificaciones'),
            trailing: Text('Predeterminado'),
            onTap: () => _showNotificationSoundDialog(context),
          ),

          // Sección de preferencias
          _buildSectionHeader('Preferencias'),
          SwitchListTile(
            title: Text('Usar tema oscuro'),
            value: _useDarkTheme,
            onChanged: (value) => setState(() => _useDarkTheme = value),
          ),
          ListTile(
            title: Text('Idioma'),
            trailing: Text(_selectedLanguage),
            onTap: () => _showLanguageDialog(context),
          ),

          // Sección de Eliminar cuenta
          _buildSectionHeader('Información'),
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

  void _showNotificationSoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar sonido de notificaciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Predeterminado'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Sonido 1'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Sonido 2'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Español'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Inglés'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
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
    final url = Uri.parse('http://192.168.1.102:3000/api/user/$userId');
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
