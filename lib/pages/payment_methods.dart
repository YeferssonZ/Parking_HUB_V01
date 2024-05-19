import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:parking_hub/pages/AuthState.dart';
import 'package:parking_hub/pages/home_screen.dart';

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
          montoContraoferta = monto;
          totalAmount = monto * widget.selectedHours;
          isLoading = false;
        });
      } else {
        print('Error al obtener la contraoferta: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al obtener la contraoferta: $e');
      setState(() {
        isLoading = false;
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
        print('Respuesta del servidor: ${response.body}');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } else {
        print('Error al actualizar la contraoferta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar la contraoferta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Métodos de Pago',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 153, 15, 40),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentInfo('Hora(s) Seleccionada(s)', '${widget.selectedHours.toStringAsFixed(1)}'),
                  _buildPaymentInfo('Monto de la Contraoferta', 'S/. ${montoContraoferta.toStringAsFixed(2)}'),
                  _buildPaymentInfo('Monto Total a Pagar', 'S/. ${totalAmount.toStringAsFixed(2)}'),
                  SizedBox(height: 32.0),
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
                            title: Row(
                              children: [
                                _buildPaymentIcon(method), // Agregar icono del método de pago
                                SizedBox(width: 12.0),
                                Text(method, style: TextStyle(fontSize: 16.0)),
                              ],
                            ),
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
                        await Future.delayed(Duration(seconds: 2)); // Simular un proceso de pago

                        await _updateContraoferta('Aceptada', selectedPaymentMethod!);

                        Navigator.of(context).pop(); // Ocultar el indicador de carga

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Pago realizado con éxito!'),
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (route) => false,
                        );
                      } catch (e) {
                        Navigator.of(context).pop(); // Ocultar el indicador de carga

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al procesar el pago'),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Confirmar Pago',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Color.fromARGB(255, 153, 15, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.0),
        ),
        SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildPaymentIcon(String method) {
    IconData icon;
    switch (method) {
      case 'Efectivo':
        icon = Icons.money;
        break;
      case 'YAPE':
        icon = Icons.phone_android;
        break;
      case 'PLIN':
        icon = Icons.payment;
        break;
      default:
        icon = Icons.credit_card;
        break;
    }
    return Icon(
      icon,
      size: 32.0,
      color: Color.fromARGB(255, 153, 15, 40),
    );
  }
}
