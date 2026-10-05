import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/drink.dart';
import '../models/ingredient.dart';

// Exceção própria: a interface pode exibir uma mensagem compreensível.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

// Toda comunicação com a API fica aqui; widgets não montam URLs nem leem JSON.
// O Client pode ser substituído nos testes, sem chamar a internet.
class CocktailApi {
  final http.Client _client;
  final String apiKey;
  final Map<String, List<String>> _listCache = {};
  CocktailApi({http.Client? client, this.apiKey = '1'})
    : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> _get(
    String endpoint,
    Map<String, String> query, {
    String root = 'drinks',
  }) async {
    final uri = Uri.https(
      'www.thecocktaildb.com',
      '/api/json/v1/$apiKey/$endpoint',
      query,
    );
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ApiException(
          'A API respondeu com erro ${response.statusCode}. Tente novamente.',
        );
      }
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic> || !data.containsKey(root)) {
        throw const ApiException('A API retornou uma resposta inesperada.');
      }
      final rows = data[root];
      // A documentação prevê tanto null quanto "None Found" para lista vazia.
      if (rows == null || rows == 'None Found') return [];
      if (rows is! List)
        throw const ApiException('Formato de dados inesperado.');
      return rows.map((row) => Map<String, dynamic>.from(row as Map)).toList();
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('A consulta demorou demais. Tente novamente.');
    } on FormatException {
      throw const ApiException('Não foi possível ler a resposta da API.');
    } catch (_) {
      throw const ApiException(
        'Não foi possível consultar os dados. Confira sua conexão e tente novamente.',
      );
    }
  }

  Future<List<DrinkSummary>> searchByName(String name) async => (await _get(
    'search.php',
    {'s': name.trim()},
  )).map(DrinkSummary.fromJson).toList();
  Future<List<DrinkSummary>> searchByLetter(String letter) async => (await _get(
    'search.php',
    {'f': letter},
  )).map(DrinkSummary.fromJson).toList();
  Future<Drink?> drinkById(String id) async {
    final rows = await _get('lookup.php', {'i': id});
    return rows.isEmpty ? null : Drink.fromJson(rows.first);
  }

  Future<List<DrinkSummary>> filter(String kind, String value) async =>
      (await _get('filter.php', {
        kind: value,
      })).map(DrinkSummary.fromJson).toList();

  // Cache em memória: evita baixar as mesmas opções ao trocar de aba.
  // Não é cache permanente: é apagado ao fechar o aplicativo.
  Future<List<String>> listValues(String kind) async {
    if (_listCache.containsKey(kind)) return _listCache[kind]!;
    const fields = {
      'c': 'strCategory',
      'g': 'strGlass',
      'i': 'strIngredient1',
      'a': 'strAlcoholic',
    };
    final rows = await _get('list.php', {kind: 'list'});
    final values =
        rows
            .map((row) => apiText(row[fields[kind]]))
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    _listCache[kind] = values;
    return values;
  }

  Future<List<Ingredient>> searchIngredients(String name) async => (await _get(
    'search.php',
    {'i': name.trim()},
    root: 'ingredients',
  )).map(Ingredient.fromJson).toList();
  Future<Ingredient?> ingredientByName(String name) async {
    final rows = await searchIngredients(name);
    if (rows.isEmpty) return null;
    return rows.firstWhere(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
      orElse: () => rows.first,
    );
  }

  Future<Ingredient?> ingredientById(String id) async {
    final rows = await _get('lookup.php', {'iid': id}, root: 'ingredients');
    return rows.isEmpty ? null : Ingredient.fromJson(rows.first);
  }

  static String ingredientImage(String name) =>
      'https://www.thecocktaildb.com/images/ingredients/${Uri.encodeComponent(name)}-medium.png';

  void close() => _client.close();
}
