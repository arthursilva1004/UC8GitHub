import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const FormExampleApp());

class FormExampleApp extends StatelessWidget {
  const FormExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Localizador')),
        body: const FormExample(),
      ),
    );
  }
}

class FormExample extends StatefulWidget {
  const FormExample({super.key});

  @override
  State<FormExample> createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _locationSaidaController =
      TextEditingController();
  final TextEditingController _locationChegadaController =
      TextEditingController();
  LatLng? _coordinatesSaida;
  LatLng? _coordinatesChegada;
  List<LatLng> _routePoints = [];

  Future<void> _searchLocation() async {
    final querySaida = _locationSaidaController.text;
    final queryChegada = _locationChegadaController.text;
    if (querySaida.isEmpty || queryChegada.isEmpty) return;

    final urlSaida = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$querySaida');
    final urlChegada = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$queryChegada');

    final responseSaida = await http.get(urlSaida);
    final responseChegada = await http.get(urlChegada);

    if (responseSaida.statusCode == 200) {
      final data = json.decode(responseSaida.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _coordinatesSaida = LatLng(lat, lon);
        });
      }
    }

    if (responseChegada.statusCode == 200) {
      final data = json.decode(responseChegada.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _coordinatesChegada = LatLng(lat, lon);
        });
        _getRoute(_coordinatesSaida!, _coordinatesChegada!);
      }
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routeGeometry = data['routes'][0]['geometry']['coordinates'];
      List<LatLng> points = routeGeometry
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
      setState(() {
        _routePoints = points;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _locationSaidaController,
                  decoration: const InputDecoration(
                    hintText: 'Coloque o ponto de saída',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira alguma localização';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationChegadaController,
                  decoration: const InputDecoration(
                    hintText: 'Coloque o ponto de chegada',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira alguma localização';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _searchLocation();
                    }
                  },
                  child: const Text('Procurar'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
                initialCenter: (_coordinatesSaida != null && _coordinatesChegada != null)
                    ? LatLng(
                        (_coordinatesSaida!.latitude + _coordinatesChegada!.latitude) / 2,
                        (_coordinatesSaida!.longitude + _coordinatesChegada!.longitude) / 2,
                      )
                    : LatLng(0, 0),
                initialZoom: (_coordinatesSaida != null && _coordinatesChegada != null)
                    ? 15.0
                    : 2.0),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (_coordinatesSaida != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _coordinatesSaida!,
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(
                        Icons.adjust_sharp,
                        color: Colors.blue,
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
              if (_coordinatesChegada != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _coordinatesChegada!,
                      width: 80.0,
                      height: 80.0,
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.black,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
