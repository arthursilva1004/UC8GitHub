import 'package:flutter/material.dart';
import 'package:pokedex/pages/home.dart';
import 'database.dart'; 
import 'dart:convert';

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: const Text("Pokedex"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
        ],
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
              child: const Icon(Icons.search_outlined, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getFavoritePokemons(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final pokemon = favorites[index];
              Map<String, dynamic> estatisticas = <String, dynamic>{};
              try {
                if (pokemon['estatisticas_basicas'] != null) {
                  estatisticas = jsonDecode(pokemon['estatisticas_basicas']) as Map<String, dynamic>;
                }
              } catch (e) {
                print('Erro ao decodificar estatísticas: $e');
                estatisticas = <String, dynamic>{};
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.network(
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            pokemon['nome'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Game'
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tipo
                      Text(
                        "Tipo: ${pokemon['tipo']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      // Habilidades
                      Text(
                        "Habilidades: ${pokemon['habilidades'].toString().replaceAll(',', ', ')}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      // Estatísticas
                      const Text(
                        "Estatísticas:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: estatisticas.entries.map((entry) {
                          return Text(
                            "${entry.key}: ${entry.value}",
                            style: const TextStyle(fontSize: 16),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Botão para remover dos favoritos
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _dbHelper.deletePokemon(pokemon['id']);
                            setState(() {}); // Atualiza a lista após remover
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}