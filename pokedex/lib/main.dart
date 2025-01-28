import 'package:flutter/material.dart';
import 'package:pokedex/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      home: Scaffold(),
    );
  }
}

class InputExample extends StatefulWidget {
  const InputExample({super.key});

  @override
  _InputExampleState createState() => _InputExampleState();
}

class _InputExampleState extends State<InputExample> {
  final TextEditingController _controller = TextEditingController();
  String pokemon = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Digite o nome do Pokemon",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                pokemon = _controller.text;
              });
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Home(pokemon: pokemon)),
              );
            },
            child: const Text("Salvar"),
          ),
          const SizedBox(height: 16),
          Text(
            "Texto digitado: $pokemon",
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
