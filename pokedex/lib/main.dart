import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pokedex/pages/home.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante que os plugins sejam carregados corretamente
  setupDatabase();
  runApp(const MyApp());
}

void setupDatabase() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      home: const InputExample(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: const Text("Pokedex"),
        backgroundColor: const Color.fromARGB(227, 227, 53, 13),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Digite o nome do Pokémon",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search_outlined),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Home(pokemon: _controller.text),
                    ),
                  );
                }
              },
              child: const Icon(Icons.search_outlined,
                  color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
