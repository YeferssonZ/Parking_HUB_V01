import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import "package:demo01/pages/AuthState.dart";
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _sliderValue = 0.0;
  bool _isNight = true;
  late GoogleMapController _mapController;
  bool _showParkingOptions = false;
  String _selectedFilter = 'Noche';
  double? _latitude; // Almacena la latitud
  double? _longitude; // Almacena la longitud

  @override
  Widget build(BuildContext context) {
    String token = Provider.of<AuthState>(context).token;
    return WillPopScope(
      onWillPop: () async => false, // Bloquear la navegación hacia atrás
      child: Scaffold(
        appBar: AppBar(
          title: Text('PARKING HUB'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.blue[100],
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 10),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Mi perfil'),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configuración'),
                  onTap: () {
                    // Navegar a la pantalla de configuración
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.policy),
                  title: Text('Términos y condiciones'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsAndConditionsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  onTap: () {
                    // Implementar acción para About
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _showLogoutConfirmationDialog(context),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  _getCurrentLocation();
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            if (_showParkingOptions)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Elegiste $_selectedFilter',
                      style: TextStyle(fontSize: 28),
                    ),
                    Text(
                      'Monto seleccionado: S/. ${_sliderValue.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Slider(
                      value: _sliderValue,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      label: 'S/. ${_sliderValue.toStringAsFixed(1)}',
                      onChanged: (newValue) {
                        setState(() {
                          _sliderValue = newValue;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => _submitForm(token),
                      child: Text('Confirmar Monto'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'x Noche';
                        _isNight = true;
                        _showParkingOptions = true;
                      });
                    },
                    child: Text('x Noche'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'x Hora';
                        _isNight = false;
                        _showParkingOptions = true;
                      });
                    },
                    child: Text('x Hora'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (e) {
      print("Error obtaining current location: $e");
    }
  }

  Future<void> _submitForm(String token) async {
    final url = Uri.parse('https://test-2-slyp.onrender.com/api/oferta');

    final requestBody = {
      'monto': _sliderValue.toStringAsFixed(2),
      'latitud': _latitude ?? 0,
      'longitud': _longitude ?? 0,
      'filtroAlquiler': _isNight ? 'true' : 'false',
    };

    final headers = {
      'Content-Type': 'application/json',
      'x-access-token': token,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showConfirmationDialog(context);
      } else {
        _showAlertDialog('Error al enviar la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog('Error al enviar la solicitud: $e');
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar sesión'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres cerrar sesión?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cerrar sesión'),
              onPressed: () {
                Provider.of<AuthState>(context, listen: false).deleteToken();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Navegar a la página de inicio y eliminar todas las rutas anteriores
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlertDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Solicitud enviada con éxito'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Esperando contraofertas o aceptación...'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
        onProgress: (int progress) {},
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        navigationDelegate: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
