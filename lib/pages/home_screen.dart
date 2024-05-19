import 'dart:async';
import 'package:parking_hub/pages/details_garage_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:webview_flutter/webview_flutter.dart';
import "package:parking_hub/pages/AuthState.dart";
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';

class PermissionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Permisos de Ubicación'),
      content: Text('La empresa Parking Hub desea que le permitas usar tu ubicación actual.'),
      actions: <Widget>[
        TextButton(
          child: Text('Permitir'),
          onPressed: () async {
            // Solicitar permisos de ubicación
            var status = await Permission.location.request();
            if (status == PermissionStatus.granted) {
              Navigator.pop(context); // Cerrar el diálogo si se otorgan los permisos
            } else {
              // Manejar el caso en el que el usuario no otorga los permisos
              // Puedes mostrar un mensaje o realizar alguna otra acción aquí
            }
          },
        ),
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.pop(context); // Cerrar el diálogo si el usuario cancela
          },
        ),
      ],
    );
  }
}


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
  Set<Circle> _circles = {}; // Conjunto de círculos en el mapa
  double _radiusInMeters = 1000.0;
  late io.Socket socket;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
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

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status != PermissionStatus.granted) {
      // Mostrar el diálogo de permisos de ubicación si no se han otorgado
      showDialog(
        context: context,
        barrierDismissible: false, // Evitar que se cierre el diálogo haciendo clic fuera de él
        builder: (BuildContext context) {
          return WillPopScope( // Evitar que el usuario cierre el diálogo con el botón "Atrás" del dispositivo
            onWillPop: () async => false,
            child: PermissionDialog(),
          );
        },
      ).then((_) {
        // Actualizar el estado después de cerrar el diálogo
        setState(() {
          _locationPermissionGranted = true;
        });
      });
    } else {
      // Si los permisos ya se han otorgado, actualizar el estado
      setState(() {
        _locationPermissionGranted = true;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    String token = Provider.of<AuthState>(context).token;
    return WillPopScope(
      onWillPop: () async => false, // Bloquear la navegación hacia atrás
      child: Scaffold(
        appBar: AppBar(
          title: Text('PARKING HUB',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 153, 15, 40),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          child: Container(
            color: Color.fromARGB(255, 200, 82, 103),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 236, 96, 121),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Color.fromARGB(255, 153, 15, 40),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.white),
                  title:
                      Text('Mi perfil', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text('Configuración',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Navegar a la pantalla de configuración
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.policy, color: Colors.white),
                  title: Text('Términos y condiciones',
                      style: TextStyle(color: Colors.white)),
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
                  leading: Icon(Icons.info, color: Colors.white),
                  title:
                      Text('Acerca de', style: TextStyle(color: Colors.white)),
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
                  leading: Icon(Icons.logout, color: Colors.white),
                  title: Text(
                    'Cerrar sesión',
                    style: TextStyle(
                        color: Color.fromARGB(255, 55, 255, 0),
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showLogoutConfirmationDialog(context),
                ),
              ],
            ),
          ),
        ),
        body: _locationPermissionGranted
          ? Column(
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
                    circles: _circles,
                  ),
                ),
                if (_showParkingOptions)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Elegiste $_selectedFilter',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Monto seleccionado: S/. ${_sliderValue.toStringAsFixed(1)}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Color.fromARGB(255, 153, 15, 40),
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: Color.fromARGB(255, 153, 15, 40),
                                overlayColor: Color.fromARGB(100, 153, 15, 40),
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                                overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                                valueIndicatorColor: Color.fromARGB(255, 153, 15, 40),
                                valueIndicatorTextStyle: TextStyle(color: Colors.white),
                              ),
                              child: Slider(
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
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Color.fromARGB(255, 153, 15, 40),
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: Color.fromARGB(255, 153, 15, 40),
                                overlayColor: Color.fromARGB(100, 153, 15, 40),
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                                overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                                valueIndicatorColor: Color.fromARGB(255, 153, 15, 40),
                                valueIndicatorTextStyle: TextStyle(color: Colors.white),
                              ),
                              child: Slider(
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
                            ),
                            // Mostrar el total a pagar según el monto y las horas seleccionadas
                            Text(
                              'Total a pagar: S/. ${_calculateTotal(_sliderValue, _hours).toStringAsFixed(1)}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _submitForm(token),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 153, 15, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Confirmar Monto y Horas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 153, 15, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Text(
                            'x Noche',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'x Hora';
                            _isNight = false;
                            _showParkingOptions = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 153, 15, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Text(
                            'x Hora',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : SizedBox(),
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
      _updateCircle(LatLng(position.latitude, position.longitude));
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

  void _updateCircle(LatLng center) {
    _circles.clear(); // Eliminar círculos existentes

    Circle circle = Circle(
      circleId: CircleId('myCircle'),
      center: center,
      radius: _radiusInMeters,
      fillColor: Colors.blue
          .withOpacity(0.2), // Color de relleno del círculo (rojo transparente)
      strokeWidth:
          0, // Ancho de la línea del borde del círculo (0 para no mostrar borde)
      visible: true, // Mostrar el círculo en el mapa
    );

    setState(() {
      _circles.add(circle); // Agregar el círculo al conjunto de círculos
    });
  }

  // Ejemplo de uso en _submitForm
  Future<void> _submitForm(String token) async {
    final url = Uri.parse('https://test-2-slyp.onrender.com/api/oferta');

    // Inicializa el sistema de internacionalización para asegurar la configuración regional correcta
    await initializeDateFormatting(
        'es_PE', null); // Utiliza 'es_PE' para español de Perú

    // Obtiene la fecha y hora actual en la zona horaria de Perú
    final currentDateTime = DateTime.now();
    final peruTimeZoneOffset = currentDateTime.timeZoneOffset;

    // Formatea la fecha y hora en el formato deseado ('yyyy-MM-dd HH:mm:ss')
    final formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss', 'es_PE').format(currentDateTime);

    // Crea el cuerpo de la solicitud con los datos requeridos
    final requestBody = {
      'monto': _sliderValue.toStringAsFixed(2),
      'latitud': _latitude ?? 0,
      'longitud': _longitude ?? 0,
      'filtroAlquiler': _isNight ? 'true' : 'false',
      'hora': _hours.toInt(), // Convierte las horas seleccionadas a entero
      'fechaHora':
          formattedDateTime, // Agrega la fecha y hora formateada al cuerpo de la solicitud
      'timeZoneOffset': peruTimeZoneOffset
          .inHours, // Agrega el offset de la zona horaria de Perú en horas
    };

    // Configura los encabezados de la solicitud HTTP
    final headers = {
      'Content-Type': 'application/json',
      'x-access-token': token,
    };

    bool receivedContraoferta =
        false; // Bandera para indicar si se recibió una contraoferta

    try {
      // Realiza la solicitud HTTP POST
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Procesa la respuesta obtenida
        final responseData = jsonDecode(response.body);
        final ofertaId = responseData['_id']; // Obtiene el ID de la oferta

        if (ofertaId != null) {
          // Muestra el diálogo de confirmación
          _showConfirmationDialog(context, ofertaId, token);

          // Programa la eliminación de la oferta después de 3 minutos
          Timer(Duration(minutes: 1), () async {
            if (!receivedContraoferta) {
              // Si no se recibió una contraoferta, eliminar la oferta
              await _deleteOffer(
                  token, ofertaId); // Elimina la oferta utilizando el ID
            }
          });

          // Escucha el evento de nueva contraoferta
          socket.on('nueva_contraOferta', (data) {
            print('Nueva contraoferta recibida: $data');
            receivedContraoferta =
                true; // Marca que se recibió una contraoferta
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

    // Inicializa el sistema de internacionalización para asegurar la configuración regional correcta
    await initializeDateFormatting(
        'es_PE', null); // Utiliza 'es_PE' para español de Perú

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
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    final formattedDateTime =
        DateFormat('dd/MM/yyyy HH:mm', 'es_PE').format(dateTime);
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
        title: Text(
          'Términos y condiciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 153, 15, 40),
        iconTheme: IconThemeData(color: Colors.white),
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
        title: Text(
          'Acerca de',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 153, 15, 40),
        iconTheme: IconThemeData(color: Colors.white),
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
