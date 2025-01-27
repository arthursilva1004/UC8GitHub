import 'package:flutter/material.dart';
import 'package:mensagem_aleatoria/mssaleatoria.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frases Aleatórias',
      home: Scaffold(
        appBar: AppBar(title: const Text("Input em Variável")),
        body: InputExample(),
      ),
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
  String nome = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Digite seu nome",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                nome = _controller.text;
              });
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Home(nome: nome)),
              );
            },
            child: const Text("Salvar"),
          ),
          const SizedBox(height: 16),
          Text(
            "Texto digitado: $nome",
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
