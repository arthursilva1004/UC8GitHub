import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  final String pokemon;

  const Home({super.key, required this.pokemon});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isFavorited = false;

  void Favoritar() {
    setState(() {
      isFavorited = !isFavorited;
    });
  }

  Map<String, dynamic>? pokemonData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> fetchPokemonData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://pokeapi.co/api/v2/pokemon/${widget.pokemon.toLowerCase()}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          pokemonData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: Text(widget.pokemon.toLowerCase()),
        backgroundColor: const Color.fromARGB(227, 227, 53, 13),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : hasError || pokemonData == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error,
                          color: Color.fromARGB(255, 248, 56, 43), size: 60),
                      const SizedBox(height: 10),
                      const Text(
                        "Pokémon não encontrado!",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 248, 56, 43)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Voltar"),
                      )
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 300,
                          child: Image.network(
                            pokemonData!['sprites']['front_default'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          "${pokemonData!['name']}",
                          style: const TextStyle(
                              fontSize: 25,
                              fontFamily: 'Game',
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "ID: ${pokemonData!['id']}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          "Nome: ${pokemonData!['name']}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          "Altura: ${pokemonData!['height'] / 10} m",
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          "Peso: ${pokemonData!['weight'] / 10} kg",
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          "Tipo: ${pokemonData!['types'].map((t) => t['type']['name']).join(', ')}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          "Habilidades: ${pokemonData!['abilities'].map((a) => a['ability']['name']).join(', ')}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          "Estatísticas básicas: ${pokemonData!['stats'].map((s) => '${s['stat']['name']}: ${s['base_stat']}').join(', ')}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: Favoritar,
                          child: Icon(
                            isFavorited ? Icons.star : Icons.star_outline,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Icon(Icons.west_outlined),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
