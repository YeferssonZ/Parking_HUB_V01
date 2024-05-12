import 'dart:async';
import 'package:demo01/pages/details_garage_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:webview_flutter/webview_flutter.dart';
import "package:demo01/pages/AuthState.dart";
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  double _hours = 1.0; // Valor inicial
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    // Conectar al servidor Socket.IO
    socket = io.io('https://test-2-slyp.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
  }

  @override
  void dispose() {
    // Desconectar y liberar recursos del socket
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

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
                  title: Text('Acerca de'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutScreen(),
                      ),
                    );
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
                      min: 0,
                      max: 50,
                      divisions: 100,
                      label: 'S/. ${_sliderValue.toStringAsFixed(1)}',
                      onChanged: (newValue) {
                        setState(() {
                          _sliderValue = newValue;
                        });
                      },
                    ),
                    Slider(
                      value: _hours,
                      min: 1,
                      max: 12,
                      divisions: 11,
                      label: '$_hours horas',
                      onChanged: (newValue) {
                        setState(() {
                          _hours = newValue;
                        });
                      },
                    ),
                    // Mostrar el total a pagar según el monto y las horas seleccionadas
                    Text(
                      'Total a pagar: S/. ${_calculateTotal(_sliderValue, _hours).toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () => _submitForm(token),
                      child: Text('Confirmar Monto y Horas'),
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

  double _calculateTotal(double montoOferta, double horas) {
    return montoOferta * horas;
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

  // Ejemplo de uso en _submitForm
  Future<void> _submitForm(String token) async {
    final url = Uri.parse('https://test-2-slyp.onrender.com/api/oferta');

    // Obtener la fecha y hora actual en formato deseado (por ejemplo, 'yyyy-MM-dd HH:mm:ss')
    final currentDateTime = DateTime.now();
    final formattedDateTime = currentDateTime
        .toString()
        .split('.')[0]; // Eliminar la parte de milisegundos

    final requestBody = {
      'monto': _sliderValue.toStringAsFixed(2),
      'latitud': _latitude ?? 0,
      'longitud': _longitude ?? 0,
      'filtroAlquiler': _isNight ? 'true' : 'false',
      'hora': _hours.toInt(), // Convertir horas seleccionadas a entero
      'fechaHora':
          formattedDateTime, // Agregar la fecha y hora formateada al cuerpo de la solicitud
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
        final responseData = jsonDecode(response.body);
        final ofertaId = responseData['_id']; // Obtener el ID de la oferta

        if (ofertaId != null) {
          _showConfirmationDialog(context, ofertaId, token);

          // Iniciar un temporizador para eliminar la oferta después de 3 minutos
          Timer(Duration(minutes: 3), () {
            _deleteOffer(token,
                ofertaId); // Pasar el ID de la oferta a la función _deleteOffer
          });
        } else {
          _showAlertDialog('Error: ID de oferta nulo');
        }
      } else {
        _showAlertDialog(
            'Error al enviar la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog('Error al enviar la solicitud: $e');
    }
  }

  Future<void> _deleteOffer(String token, String ofertaId) async {
    final deleteUrl =
        Uri.parse('https://test-2-slyp.onrender.com/api/oferta/$ofertaId');

    try {
      final response = await http.delete(
        deleteUrl,
        headers: {'x-access-token': token},
      );

      if (response.statusCode == 200) {
        // Oferta eliminada correctamente
        print('Oferta eliminada correctamente');
      } else {
        // Error al eliminar la oferta
        print('Error al eliminar la oferta: ${response.statusCode}');
      }
    } catch (e) {
      // Error de conexión o solicitud
      print('Error al eliminar la oferta: $e');
    }
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

  Future<void> _showContraofertasDialog(List<dynamic> contraofertas) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contraofertas'),
          content: SingleChildScrollView(
            child: ListBody(
              children: contraofertas.map((contraoferta) {
                return ListTile(
                  title: Text('Monto: ${contraoferta['monto']}'),
                  subtitle: Text('Estado: ${contraoferta['estado']}'),
                );
              }).toList(),
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

  Future<void> _showConfirmationDialog(
      BuildContext context, String ofertaId, String token) async {
    List<dynamic> contraofertas = [];
    bool isDialogOpen = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (!isDialogOpen) {
              isDialogOpen = true;

              socket.on('nueva_contraOferta', (data) {
                print('Nueva contraoferta recibida: $data');
                bool isDuplicate =
                    contraofertas.any((oferta) => oferta['_id'] == data['_id']);
                if (!isDuplicate) {
                  setState(() {
                    contraofertas.add(data);
                  });
                }
              });
            }

            return AlertDialog(
              title: Text('Solicitud enviada con éxito'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: contraofertas.isEmpty
                      ? [Text('Esperando contraofertas...')]
                      : contraofertas.map((contraoferta) {
                          return ListTile(
                            title: Text('Monto: ${contraoferta['monto']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Estado: ${contraoferta['estado']}'),
                                Text(
                                    'Fecha y hora: ${_formatDateTime(contraoferta['createdAt'])}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () {
                                    _acceptOffer(context, contraoferta);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    _removeOffer(contraoferta);
                                    setState(() {
                                      contraofertas.remove(contraoferta);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () {
                    socket.off('nueva_contraOferta');
                    isDialogOpen = false;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDateTime = DateFormat('dd/MM/yyyy HH:mm')
        .format(dateTime);
    return formattedDateTime;
  }

  void _acceptOffer(BuildContext context, dynamic contraoferta) {
    print('Aceptaste esta contraoferta: $contraoferta');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Oferta aceptada!'),
          content: Text('Aceptaste esta oferta. Redirigiendo...'),
        );
      },
    );

    // Redireccionar a la pantalla de detalles del garaje después de 5 segundos
    Future.delayed(Duration(seconds: 5), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsGaragePage(
            garageId: contraoferta['garage'],
            selectedHours: _hours,
            ofertaId: contraoferta['_id'],
          ),
        ),
      );
    });
  }

  void _removeOffer(dynamic contraoferta) async {
    print('Eliminaste esta contraoferta: $contraoferta');

    final String contraofertaId =
        contraoferta['_id']; // Obtener el ID de la contraoferta

    final url = Uri.parse(
        'https://test-2-slyp.onrender.com/api/contraoferta/$contraofertaId');

    final headers = {
      'Content-Type': 'application/json',
      // Aquí podrías incluir cualquier otro encabezado necesario, como el token de acceso
    };

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Contraoferta eliminada correctamente
        print('Contraoferta eliminada correctamente');
      } else {
        // Error al eliminar la contraoferta
        print('Error al eliminar la contraoferta: ${response.statusCode}');
      }
    } catch (e) {
      // Error de conexión o solicitud
      print('Error al eliminar la contraoferta: $e');
    }
  }

  Future<List<dynamic>> _fetchContraofertas(
      String ofertaId, String token) async {
    final url = Uri.parse(
        'https://test-2-slyp.onrender.com/api/contraoferta?oferta=$ofertaId');

    try {
      final response = await http.get(
        url,
        headers: {'x-access-token': token},
      );

      if (response.statusCode == 200) {
        List<dynamic> contraofertas = jsonDecode(response.body);
        return contraofertas;
      } else {
        return [];
      }
    } catch (e) {
      print('Error al obtener contraofertas: $e');
      return [];
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
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) =>
                        false); // Navegar a la página de inicio y eliminar todas las rutas anteriores
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
        initialUrl: 'https://terminos-condiciones-nine.vercel.app/',
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

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de'),
      ),
      body: WebView(
        initialUrl: 'https://github.com/YeferssonZ',
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
