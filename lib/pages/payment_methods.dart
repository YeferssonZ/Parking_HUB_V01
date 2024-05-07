import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:demo01/pages/AuthState.dart';
import 'package:uuid/uuid.dart';

class PayMethodsPage extends StatefulWidget {
  final double selectedHours;
  final String ofertaId;

  const PayMethodsPage({
    Key? key,
    required this.selectedHours,
    required this.ofertaId,
  }) : super(key: key);

  @override
  _PayMethodsPageState createState() => _PayMethodsPageState();
}

class _PayMethodsPageState extends State<PayMethodsPage> {
  List<String> paymentMethods = ['Efectivo', 'YAPE', 'PLIN'];
  String? selectedPaymentMethod;
  double totalAmount = 0.0;
  double montoContraoferta = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContraofertaAndCalculateAmount();
  }

  Future<void> _fetchContraofertaAndCalculateAmount() async {
    final String ofertaId = widget.ofertaId;
    final url = Uri.parse('https://test-2-slyp.onrender.com/api/contraoferta/$ofertaId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final double monto = (data['monto'] ?? 0).toDouble();
        setState(() {
          montoContraoferta = monto; // Almacenar el monto de la contraoferta
          totalAmount = monto * widget.selectedHours;
          isLoading = false; // Finaliza la carga
        });
      } else {
        print('Error al obtener la contraoferta: ${response.statusCode}');
        setState(() {
          isLoading = false; // Finaliza la carga incluso en caso de error
        });
      }
    } catch (e) {
      print('Error al obtener la contraoferta: $e');
      setState(() {
        isLoading = false; // Finaliza la carga en caso de excepción
      });
    }
  }

  Future<void> _updateContraoferta(String estado, String pago) async {
    final String contraofertaId = widget.ofertaId;
    final String url = 'https://test-2-slyp.onrender.com/api/contraoferta/$contraofertaId';

    final Map<String, String> body = {
      'estado': estado,
      'pago': pago,
    };

    String token = Provider.of<AuthState>(context, listen: false).token;

    try {
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': token,
        },
      );

      if (response.statusCode == 200) {
        print('Contraoferta actualizada exitosamente');
        print('Respuesta de OneSignal: ${response.body}');

        // Obtener información del propietario (userID)
        final dynamic data = jsonDecode(response.body);
        final ownerId = data['user']; // ID del propietario obtenido de la API contraoferta

        // Convertir el ownerId a UUID válido
        String ownerUUID = toValidUUID(ownerId);

        // Enviar notificación al propietario
        await _sendNotificationToOwner(ownerUUID);
      } else {
        print('Error al actualizar la contraoferta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar la contraoferta: $e');
    }
  }

  // Función para convertir un ID en un UUID válido
  String toValidUUID(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (uuidRegex.hasMatch(id)) {
      return id; // El ID ya es un UUID válido
    } else {
      // Generar un nuevo UUID basado en el ID proporcionado
      Uuid uuid = Uuid();
      String generatedUUID = uuid.v5(Uuid.NAMESPACE_URL, id);
      return generatedUUID;
    }
  }

  Future<void> _sendNotificationToOwner(String ownerId) async {
    final String notificationUrl = 'https://onesignal.com/api/v1/notifications';

    final Map<String, dynamic> notificationData = {
      'app_id': 'd9f94d6b-d05c-4268-98af-7cd5c052fe9c',
      'include_player_ids': [ownerId],
      'contents': {
        'en': '¡Un usuario ha aceptado la contraoferta y alquilará tu garage por ${widget.selectedHours} horas y te pagará con $selectedPaymentMethod al acercarse al establecimiento!',
      },
    };

    try {
      final response = await http.post(
        Uri.parse(notificationUrl),
        body: jsonEncode(notificationData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'NjU1YTBlOTAtNTFkMS00YjA3LWFiOGMtNmE2Mzc0ZTdlYWU0',
        },
      );

      if (response.statusCode == 200) {
        print('Notificación enviada al propietario');
      } else {
        print('Error al enviar la notificación al propietario: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar la notificación al propietario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Métodos de Pago'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hora(s) Seleccionada(s): ${widget.selectedHours.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Monto de la Contraoferta: S/. ${montoContraoferta.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Monto Total a Pagar: S/. ${totalAmount.toStringAsFixed(2)}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Selecciona un método de pago:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 16.0),
                  Column(
                    children: paymentMethods
                        .map(
                          (method) => RadioListTile<String>(
                            value: method,
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value;
                              });
                            },
                            title: Text(method),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedPaymentMethod == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selecciona un método de pago'),
                          ),
                        );
                        return;
                      }

                      // Mostrar un indicador de carga
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );

                      try {
                        // Simular un proceso de pago asincrónico
                        await Future.delayed(Duration(seconds: 2));

                        // Actualizar el estado y pago de la contraoferta
                        await _updateContraoferta(
                            'Aceptada', selectedPaymentMethod!);

                        Navigator.of(context)
                            .pop(); // Ocultar el indicador de carga

                        // Mostrar mensaje de confirmación
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Pago realizado con éxito!'),
                          ),
                        );

                        // Volver a la pantalla anterior
                        Navigator.pop(context);
                      } catch (e) {
                        // En caso de error, mostrar un mensaje de error
                        Navigator.of(context)
                            .pop(); // Ocultar el indicador de carga

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al procesar el pago'),
                          ),
                        );
                      }
                    },
                    child: Text('Confirmar Pago'),
                  ),
                ],
              ),
            ),
    );
  }
}
