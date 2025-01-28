import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  final String pokemon;

  Home({super.key, required this.pokemon});
  var request = http.Request(
      'GET', Uri.parse('https://pokeapi.co/api/v2/pokemon/${pokemon}'));
      
  http.StreamedResponse response = await request.send();
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
        backgroundColor: const Color.fromARGB(255, 214, 218, 221),
      ),
    );
  }
}
