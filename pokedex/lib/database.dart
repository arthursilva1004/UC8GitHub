import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pokemonsFav.db');

    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE pokemonsFavoritos(id INTEGER PRIMARY KEY, nome TEXT, altura REAL, peso REAL, tipo TEXT, habilidades TEXT, estatisticas_basicas TEXT)',
    );
  }

  Future<List<Map<String, dynamic>>> getFavoritePokemons() async {
    final db = await database;
    return db.query('pokemonsFavoritos');
  }

  Future<void> insertPokemon(Map<String, dynamic> pokemon) async {
    final db = await database;
    await db.insert(
      'pokemonsFavoritos',
      pokemon,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deletePokemon(int id) async {
    final db = await database;
    await db.delete(
      'pokemonsFavoritos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countFavorites() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pokemonsFavoritos'),
    );
    return count ?? 0;
  }
}