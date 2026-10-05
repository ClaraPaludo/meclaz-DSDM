// TESTES: verificam o comportamento usando dados simulados; não alteram as telas do aplicativo.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Disponibiliza jsonDecode/jsonEncode para converter entre texto JSON e objetos.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// Importa o pacote de rede com o apelido http para identificar seus tipos.
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
// Importa os modelos que organizam os dados recebidos da API.
import 'package:meclaz_drinks/models/drink.dart';
// Importa o serviço responsável por consultar a TheCocktailDB.
import 'package:meclaz_drinks/services/cocktail_api.dart';

void main() {
  // Define um cenário automático: o texto nomeia o comportamento verificado.
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
    // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
    expect(drink.ingredients.map((e) => e.name), ['Gin', 'Lime']);
    // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
    expect(drink.ingredients.last.measure, isNull);
  });
  // Define um cenário automático: o texto nomeia o comportamento verificado.
  test('Trata os dois formatos de busca vazia', () async {
    for (final empty in [null, 'None Found']) {
      final api = CocktailApi(
        // Substitui a internet por respostas controladas, para tornar o teste previsível.
        client: MockClient(
          (_) async => http.Response(jsonEncode({'drinks': empty}), 200),
        ),
      );
      // Agenda uma limpeza que será executada depois do teste, mesmo se ele falhar.
      addTearDown(api.close);
      // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
      expect(await api.searchByName('inexistente'), isEmpty);
    }
  });
  // Define um cenário automático: o texto nomeia o comportamento verificado.
  test('Codifica consulta e preserva valor original do filtro', () async {
    final api = CocktailApi(
      // Substitui a internet por respostas controladas, para tornar o teste previsível.
      client: MockClient((request) async {
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(request.url.queryParameters, {'c': 'Coffee / Tea'});
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(request.url.path, '/api/json/v1/1/filter.php');
        return http.Response(
          '{"drinks": [{"idDrink":"10","strDrink":"Café"}]}',
          200,
        );
      }),
    );
    // Agenda uma limpeza que será executada depois do teste, mesmo se ele falhar.
    addTearDown(api.close);
    // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
    expect((await api.filter('c', 'Coffee / Tea')).single.id, '10');
  });
  // Define um cenário automático: o texto nomeia o comportamento verificado.
  test('Lê strIngredient1 e guarda as listas em cache', () async {
    var calls = 0;
    final api = CocktailApi(
      // Substitui a internet por respostas controladas, para tornar o teste previsível.
      client: MockClient((_) async {
        calls++;
        return http.Response(
          '{"drinks":[{"strIngredient1":"Gin"},{"strIngredient1":"Gin"}]}',
          200,
        );
      }),
    );
    // Agenda uma limpeza que será executada depois do teste, mesmo se ele falhar.
    addTearDown(api.close);
    // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
    expect(await api.listValues('i'), ['Gin']);
    await api.listValues('i');
    // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
    expect(calls, 1);
  });
  // Define um cenário automático: o texto nomeia o comportamento verificado.
  test('Converte falhas HTTP e JSON inválido em ApiException', () async {
    for (final response in [
      http.Response('falhou', 503),
      http.Response('<html>', 200),
      http.Response('{"drinks":42}', 200),
    ]) {
      final api = CocktailApi(client: MockClient((_) async => response));
      // Agenda uma limpeza que será executada depois do teste, mesmo se ele falhar.
      addTearDown(api.close);
      // Espera o resultado da operação e confere se ela produz a falha esperada.
      await expectLater(api.searchByName('Gin'), throwsA(isA<ApiException>()));
    }
  });
  // Define um cenário automático: o texto nomeia o comportamento verificado.
  test('Consulta ingrediente por ID na raiz ingredients', () async {
    final api = CocktailApi(
      // Substitui a internet por respostas controladas, para tornar o teste previsível.
      client: MockClient((request) async {
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(request.url.queryParameters, {'iid': '1'});
        return http.Response(
          '{"ingredients":[{"idIngredient":"1","strIngredient":"Gin","strABV":"40"}]}',
          200,
        );
      }),
    );
    // Agenda uma limpeza que será executada depois do teste, mesmo se ele falhar.
    addTearDown(api.close);
    // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
    expect((await api.ingredientById('1'))?.abv, '40');
  });
}
