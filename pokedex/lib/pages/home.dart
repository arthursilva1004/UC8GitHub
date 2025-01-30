import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/database.dart';
import 'dart:convert';

class Pokemon {
  final int id;
  final String nome;
  final double altura;
  final double peso;
  final String tipo;
  final List<String> habilidades;
  final Map<String, int> estatisticas;

  Pokemon({
    required this.id,
    required this.nome,
    required this.altura,
    required this.peso,
    required this.tipo,
    required this.habilidades,
    required this.estatisticas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'altura': altura,
      'peso': peso,
      'tipo': tipo,
      'habilidades': habilidades.join(','), // Converte a lista em uma string separada por vírgulas
      'estatisticas_basicas': jsonEncode(estatisticas), // Converte o mapa em JSON
    };
  }
}

class Home extends StatefulWidget {
  final String pokemon;

  const Home({super.key, required this.pokemon});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isFavorited = false;
  Map<String, dynamic>? pokemonData;
  bool isLoading = true;
  bool hasError = false;

  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instância do DatabaseHelper

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> _checkIfFavorited() async {
    try {
      if (pokemonData != null) {
        final favorites = await _dbHelper.getFavoritePokemons();
        final isFavorite = favorites.any((favorite) => favorite['nome'] == pokemonData!['name']);
        if (isFavorite) {
          setState(() {
            isFavorited = true;
          });
        }
      }
    } catch (e) {
      print('Erro ao verificar favoritos: $e');
    }
  }

  Future<void> toggleFavorite() async {
    if (pokemonData != null) {
      var poke = Pokemon(
        id: pokemonData!['id'],
        nome: pokemonData!['name'],
        altura: pokemonData!['height'] / 10,
        peso: pokemonData!['weight'] / 10,
        tipo: (pokemonData!['types'] as List)
            .map<String>((t) => t['type']['name'].toString())
            .join(', '),
        habilidades: (pokemonData!['abilities'] as List)
            .map<String>((a) => a['ability']['name'].toString())
            .toList(),
        estatisticas: {
          for (var s in pokemonData!['stats']) s['stat']['name']: s['base_stat']
        },
      );

      if (!isFavorited) {
        final count = await _dbHelper.countFavorites();
        if (count >= 6) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Limite atingido"),
                content: const Text("Você já tem 6 favoritos. Remova um antes de adicionar outro."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
          return;
        }
        await _dbHelper.insertPokemon(poke.toMap());
      } else {
        await _dbHelper.deletePokemon(poke.id);
      }

      setState(() {
        isFavorited = !isFavorited;
      });
    }
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
        _checkIfFavorited(); // Verifica se o Pokémon já é favorito
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
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : hasError || pokemonData == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 10),
                      const Text("Pokémon não encontrado!",
                          style: TextStyle(fontSize: 20, color: Colors.red)),
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
                        Image.network(
                          pokemonData!['sprites']['front_default'],
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                        Text("${pokemonData!['name']}",
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Game')),
                        Text("ID: ${pokemonData!['id']}"),
                        Text("Altura: ${pokemonData!['height'] / 10} m"),
                        Text("Peso: ${pokemonData!['weight'] / 10} kg"),
                        Text(
                            "Tipo: ${pokemonData!['types'].map((t) => t['type']['name']).join(', ')}"),
                        Text(
                            "Habilidades: ${pokemonData!['abilities'].map((a) => a['ability']['name']).join(', ')}"),
                        Text(
                            "Estatísticas: ${pokemonData!['stats'].map((s) => '${s['stat']['name']}: ${s['base_stat']}').join(', ')}"),
                        ElevatedButton(
                          onPressed: toggleFavorite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Icon(
                            isFavorited ? Icons.star : Icons.star_border,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}