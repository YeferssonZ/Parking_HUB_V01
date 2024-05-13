import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parking_hub/pages/payment_methods.dart';

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
  bool _isImageExpanded = false;

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
        final garageData = data.firstWhere((garage) => garage['_id'] == widget.garageId);
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
        title: Text(
          'Detalles del Garaje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 153, 15, 40),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _garageData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isImageExpanded = true;
                      });
                    },
                    child: _buildImageWidget(),
                  ),
                  SizedBox(height: 24.0),
                  _buildDetail('Dirección', _garageData!['address'], Icons.location_on),
                  SizedBox(height: 16.0),
                  _buildDetail('Descripción', _garageData!['description'], Icons.description),
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
                      'Seleccionar Método de Pago',
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

  Widget _buildImageWidget() {
    return AspectRatio(
      aspectRatio: 16 / 9, // Proporción de aspecto deseada (16:9)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isImageExpanded = !_isImageExpanded;
            });
          },
          child: Image.network(
            _garageData!['imagen']['secure_url'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.0,
              color: Color.fromARGB(255, 153, 15, 40),
            ),
            SizedBox(width: 8.0),
            Text(
              title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 153, 15, 40)),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}
