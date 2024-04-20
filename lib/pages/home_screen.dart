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
  const HomePage({
    Key? key,
  }) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: Text('PARKING HUB'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
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
                // Implementar acción para Mi perfil
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
              title: Text('Cerrar sesión'),
              onTap: () {
                // Cerrar sesión y navegar a la página de inicio de sesión
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
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
              myLocationEnabled: true, // Mostrar el botón de "Mi ubicación"
              myLocationButtonEnabled:
                  true, // Mostrar el botón azulito para la ubicación actual
            ),
          ),
          if (_showParkingOptions)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Elegiste $_selectedFilter',
                  style: TextStyle(fontSize: 28),),
                  Text(
                    
                    'Monto seleccionado: S/. ${_sliderValue.toStringAsFixed(1)}', // Muestra el valor actual del slider
                    style: TextStyle(fontSize: 18),
                  ),
                  Slider(
                    value: _sliderValue, // Valor actual del slider
                    min: 0.0, // Valor mínimo
                    max: 100.0, // Valor máximo
                    divisions:
                        100, // Divisiones para permitir incrementos de 0.1
                    label:
                        'S/. ${_sliderValue.toStringAsFixed(1)}', // Etiqueta que muestra el valor actual
                    onChanged: (newValue) {
                      setState(() {
                        _sliderValue =
                            newValue; // Actualiza el valor del slider
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => _submitForm(token),
                    child: Text('Confirmar Monto'),

                  ),

                  // Aquí puedes agregar las opciones de estacionamiento según el filtro seleccionado
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
    );
  }

  Future<void> _getCurrentLocation() async {
    // Verificar si se tienen los permisos de ubicación
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      // Permiso denegado por el usuario
      return;
    }

    // Intentar obtener la ubicación actual
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitude = position.latitude; // Asignar latitud
      _longitude = position.longitude; // Asignar longitud
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
    final url = Uri.parse('https://parking-back-pt6g.onrender.com/api/oferta');

    final requestBody = {
      'monto': _sliderValue.toStringAsFixed(2),
      'latitud': _latitude ?? 0, // Puedes cambiar esto con la ubicación real
      'longitud': _longitude ?? 0, // Puedes cambiar esto con la ubicación real
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
        print('Solicitud enviada con éxito');
        // Puedes manejar el resultado exitoso aquí
      } else {
        print('Error al enviar la solicitud: ${response.statusCode}');
        // Manejo de errores aquí
      }
    } catch (e) {
      print('Error al enviar la solicitud: $e');
      // Manejo de excepciones aquí
    }
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
        onProgress: (int progress) {
          // Aquí puedes manejar el progreso de la carga de la página si lo deseas.
        },
        onPageStarted: (String url) {
          // Se llama cuando la página web ha comenzado a cargarse.
        },
        onPageFinished: (String url) {
          // Se llama cuando la página web ha terminado de cargarse.
        },
        onWebResourceError: (WebResourceError error) {
          // Se llama si ocurre algún error al cargar la página web.
        },
        navigationDelegate: (NavigationRequest request) {
          // Puedes personalizar cómo manejar las solicitudes de navegación.
          // Por ejemplo, para prevenir la navegación a ciertas URL.
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
