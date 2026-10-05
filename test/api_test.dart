import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zest_drinks/models/drink.dart';
import 'package:zest_drinks/services/cocktail_api.dart';

void main() {
  test('Mantém pares de ingrediente e medida mesmo com lacunas', () {
    final drink = Drink.fromJson({
      'idDrink': '7',
      'strDrink': 'Teste',
      'strIngredient1': 'Gin',
      'strMeasure1': '30 ml',
      'strIngredient2': ' ',
      'strMeasure2': 'ignorar',
      'strIngredient3': 'Lime',
      'strMeasure3': null,
    });
    expect(drink.ingredients.map((e) => e.name), ['Gin', 'Lime']);
    expect(drink.ingredients.last.measure, isNull);
  });
  test('Trata os dois formatos de busca vazia', () async {
    for (final empty in [null, 'None Found']) {
      final api = CocktailApi(
        client: MockClient(
          (_) async => http.Response(jsonEncode({'drinks': empty}), 200),
        ),
      );
      addTearDown(api.close);
      expect(await api.searchByName('inexistente'), isEmpty);
    }
  });
  test('Codifica consulta e preserva valor original do filtro', () async {
    final api = CocktailApi(
      client: MockClient((request) async {
        expect(request.url.queryParameters, {'c': 'Coffee / Tea'});
        expect(request.url.path, '/api/json/v1/1/filter.php');
        return http.Response(
          '{"drinks": [{"idDrink":"10","strDrink":"Café"}]}',
          200,
        );
      }),
    );
    addTearDown(api.close);
    expect((await api.filter('c', 'Coffee / Tea')).single.id, '10');
  });
  test('Lê strIngredient1 e guarda as listas em cache', () async {
    var calls = 0;
    final api = CocktailApi(
      client: MockClient((_) async {
        calls++;
        return http.Response(
          '{"drinks":[{"strIngredient1":"Gin"},{"strIngredient1":"Gin"}]}',
          200,
        );
      }),
    );
    addTearDown(api.close);
    expect(await api.listValues('i'), ['Gin']);
    await api.listValues('i');
    expect(calls, 1);
  });
  test('Converte falhas HTTP e JSON inválido em ApiException', () async {
    for (final response in [
      http.Response('falhou', 503),
      http.Response('<html>', 200),
      http.Response('{"drinks":42}', 200),
    ]) {
      final api = CocktailApi(client: MockClient((_) async => response));
      addTearDown(api.close);
      await expectLater(api.searchByName('Gin'), throwsA(isA<ApiException>()));
    }
  });
  test('Consulta ingrediente por ID na raiz ingredients', () async {
    final api = CocktailApi(
      client: MockClient((request) async {
        expect(request.url.queryParameters, {'iid': '1'});
        return http.Response(
          '{"ingredients":[{"idIngredient":"1","strIngredient":"Gin","strABV":"40"}]}',
          200,
        );
      }),
    );
    addTearDown(api.close);
    expect((await api.ingredientById('1'))?.abv, '40');
  });
}
