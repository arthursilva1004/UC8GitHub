import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      'habilidades': jsonEncode(habilidades.join(', ')),
      'estatisticas_basicas': jsonEncode(estatisticas).toString(),
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
  Database? _database;
  Map<String, dynamic>? pokemonData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    fetchPokemonData();
  }

  Future<void> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    _database = await openDatabase(
      join(await getDatabasesPath(), 'pokemonsFav.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pokemonsFavoritos(id INTEGER PRIMARY KEY, nome TEXT, altura REAL, peso REAL, tipo TEXT, habilidades TEXT, estatisticas_basicas TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertPokemon(Pokemon pokemon) async {
    try {
      final db = _database;
      if (db != null) {
        await db.insert(
          'pokemonsFavoritos',
          pokemon.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Pokemon inserido: ${pokemon.nome}');
    } catch (e) {
      print('Erro ao inserir Pokemon: $e');
    }
  }

  Future<void> deletePokemon(int id) async {
    try {
      final db = _database;
      if (db != null) {
        await db.delete(
          'pokemonsFavoritos',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      print('Pokemon deletado: $id');
    } catch (e) {
      print('Erro ao deletar Pokemon: $e');
    }
  }

  void toggleFavorite() async {
    setState(() {
      isFavorited = !isFavorited;
    });

    if (pokemonData != null) {
      var poke = Pokemon(
        id: pokemonData!['id'],
        nome: pokemonData!['name'],
        altura: pokemonData!['height'] / 10,
        peso: pokemonData!['weight'] / 10,
        tipo: pokemonData!['types']
            .map<String>((t) => t['type']['name'].toString())
            .join(', '),
        habilidades: pokemonData!['abilities']
            .map<String>((a) => a['ability']['name'].toString())
            .toList(),
        estatisticas: {
          for (var s in pokemonData!['stats']) s['stat']['name']: s['base_stat']
        },
      );

      if (isFavorited) {
        await insertPokemon(poke);
      } else {
        await deletePokemon(poke.id);
      }
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
