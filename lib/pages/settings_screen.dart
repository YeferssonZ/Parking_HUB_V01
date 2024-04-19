import 'package:flutter/material.dart';

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

          // Sección de información
          _buildSectionHeader('Información'),
          ListTile(
            title: Text('Acerca de'),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
          ListTile(
            title: Text('Cerrar sesión'),
            onTap: () => _logout(context),
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

  void _logout(BuildContext context) async {
    // Implement logout logic here (e.g., remove user data, call an API)
    // ...
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
}
