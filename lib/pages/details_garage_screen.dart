import 'dart:convert';
import 'package:parking_hub/pages/payment_methods.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailsGaragePage extends StatefulWidget {
  final String garageId;
  final double selectedHours;
  final String ofertaId;

  const DetailsGaragePage({
    Key? key,
    required this.garageId,
    required this.selectedHours,
    required this.ofertaId,
  }) : super(key: key);

  @override
  _DetailsGaragePageState createState() => _DetailsGaragePageState();
}

class _DetailsGaragePageState extends State<DetailsGaragePage> {
  Map<String, dynamic>? _garageData;

  @override
  void initState() {
    super.initState();
    _fetchGarageData();
  }

  Future<void> _fetchGarageData() async {
    final url = Uri.parse('https://test-2-slyp.onrender.com/api/garage/allgarage');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final garageData =
            data.firstWhere((garage) => garage['_id'] == widget.garageId);
        setState(() {
          _garageData = garageData;
        });
      } else {
        print('Error al obtener los datos del garaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener los datos del garaje: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Garaje'),
      ),
      body: _garageData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/parking_app_background.jpg',
                      image: _garageData!['imagen']['secure_url'],
                      fit: BoxFit.cover,
                      height: 200.0,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Dirección:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _garageData!['address'],
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Descripción:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _garageData!['description'],
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Horas Seleccionadas:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.selectedHours.toStringAsFixed(1),
                    style: TextStyle(fontSize: 16.0),
                  ),            
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PayMethodsPage(
                            ofertaId: widget.ofertaId,
                            selectedHours: widget.selectedHours,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Seleccionar método de pago',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
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
}
