// SERVIÇO DA API: centraliza as consultas à internet e o tratamento das respostas.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Permite reconhecer TimeoutException, o erro de tempo de espera excedido.
import 'dart:async';
// Disponibiliza jsonDecode/jsonEncode para converter entre texto JSON e objetos.
import 'dart:convert';

// Importa o pacote de rede com o apelido http para identificar seus tipos.
import 'package:http/http.dart' as http;

// Importa os modelos que organizam os dados recebidos da API.
import '../models/drink.dart';
// Importa os modelos que organizam os dados recebidos da API.
import '../models/ingredient.dart';

// Exceção própria: a interface pode exibir uma mensagem compreensível.
class ApiException implements Exception {
  final String message;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const ApiException(this.message);
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  String toString() => message;
}

// Toda comunicação com a API fica aqui; widgets não montam URLs nem leem JSON.
// O Client pode ser substituído nos testes, sem chamar a internet.
class CocktailApi {
  // Cliente que envia as requisições. O _ torna o nome privado à biblioteca Dart.
  final http.Client _client;
  // Chave colocada na URL para identificar o acesso à API.
  final String apiKey;
  // Dicionário em memória: cada tipo de filtro aponta para sua lista de opções.
  final Map<String, List<String>> _listCache = {};
  // Aceita um cliente de testes; se não receber chave, usa 1, própria para estudos.
  CocktailApi({http.Client? client, this.apiKey = '1'})
    // Usa o cliente recebido ou cria um novo cliente HTTP quando ele não foi passado.
    : _client = client ?? http.Client();

  Future<List<DrinkSummary>> filterByIngredients(
    List<String> ingredients,
  ) async {
    final names = ingredients
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    if (names.length < 2) return [];

    final lists = await Future.wait(names.map((name) => filter('i', name)));

    final commonIds = lists.first.map((drink) => drink.id).toSet();

    for (final list in lists.skip(1)) {
      commonIds.retainAll(list.map((drink) => drink.id).toSet());
    }

    return lists.first.where((drink) => commonIds.contains(drink.id)).toList();
  }

  // Método interno comum às consultas. Entrega no futuro uma lista de mapas JSON.
  Future<List<Map<String, dynamic>>> _get(
    // Nome do arquivo da API, como search.php ou lookup.php.
    String endpoint,
    // Parâmetros de consulta: por exemplo, s associado ao nome Margarita.
    Map<String, String> query, {
    // Chave que contém os resultados no JSON; algumas consultas usam ingredients.
    String root = 'drinks',
  }) async {
    // Monta uma URL HTTPS e codifica corretamente espaços e caracteres da pesquisa.
    final uri = Uri.https(
      'www.thecocktaildb.com',
      '/api/json/v1/$apiKey/$endpoint',
      query,
    );
    try {
      // Envia a chamada e espera sua resposta; await não bloqueia o desenho da tela.
      final response = await _client
          // Faz uma requisição GET, que apenas consulta os dados.
          .get(uri)
          // Interrompe a espera após 20 segundos e gera um erro de tempo excedido.
          .timeout(const Duration(seconds: 20));
      // 200 significa sucesso esperado; outro status vira um erro compreensível.
      if (response.statusCode != 200) {
        throw ApiException(
          'A API respondeu com erro ${response.statusCode}. Tente novamente.',
        );
      }
      // Converte o corpo da resposta, que é texto JSON, em objetos Dart.
      final data = jsonDecode(response.body);
      // Confere se a resposta é um mapa e se contém a chave de resultados esperada.
      if (data is! Map<String, dynamic> || !data.containsKey(root)) {
        throw const ApiException('A API retornou uma resposta inesperada.');
      }
      // Extrai a lista de dentro de drinks ou ingredients.
      final rows = data[root];
      // A documentação prevê tanto null quanto "None Found" para lista vazia.
      // Os dois formatos de ausência de resultados viram a mesma lista vazia.
      if (rows == null || rows == 'None Found') return [];
      // Rejeita dados de um tipo diferente de lista para não interpretar conteúdo inválido.
      if (rows is! List)
        throw const ApiException('Formato de dados inesperado.');
      // Converte cada item em um mapa com chaves de texto e reúne todos em uma lista.
      return rows.map((row) => Map<String, dynamic>.from(row as Map)).toList();
      // Reconhece os erros que já receberam uma mensagem própria neste serviço.
    } on ApiException {
      // Repassa o erro já tratado, conservando a mensagem específica.
      rethrow;
      // Trata especificamente quando o tempo máximo da consulta se esgota.
    } on TimeoutException {
      throw const ApiException('A consulta demorou demais. Tente novamente.');
      // Trata especificamente uma resposta que não pôde ser interpretada como JSON.
    } on FormatException {
      throw const ApiException('Não foi possível ler a resposta da API.');
      // Captura uma falha para convertê-la em uma mensagem em vez de deixar a tela sem tratamento.
    } catch (_) {
      throw const ApiException(
        'Não foi possível consultar os dados. Confira sua conexão e tente novamente.',
      );
    }
  }

  // Busca drinks pelo nome com s; transforma cada resposta em um resumo para os cartões.
  Future<List<DrinkSummary>> searchByName(String name) async => (await _get(
    'search.php',
    {'s': name.trim()},
  )).map(DrinkSummary.fromJson).toList();
  // Busca drinks pela primeira letra com f; retorna os resumos encontrados.
  Future<List<DrinkSummary>> searchByLetter(String letter) async => (await _get(
    'search.php',
    {'f': letter},
  )).map(DrinkSummary.fromJson).toList();
  // Consulta uma receita completa pelo identificador; null significa que não foi encontrada.
  Future<Drink?> drinkById(String id) async {
    final rows = await _get('lookup.php', {'i': id});
    return rows.isEmpty ? null : Drink.fromJson(rows.first);
  }

  // Busca por um único critério: kind informa o tipo e value informa a opção escolhida.
  Future<List<DrinkSummary>> filter(String kind, String value) async {
    final rows = await _get('filter.php', {
      kind: value.trim().replaceAll(' ', '_'),
    });

    return rows.map(DrinkSummary.fromJson).toList();
  }

  // Cache em memória: evita baixar as mesmas opções ao trocar de aba.
  // Não é cache permanente: é apagado ao fechar o aplicativo.
  // Obtém as opções do filtro; reaproveita o cache se esta lista já foi consultada.
  Future<List<String>> listValues(String kind) async {
    // Se já baixou este filtro, devolve o cache. O ! afirma que o valor existe aqui.
    if (_listCache.containsKey(kind)) return _listCache[kind]!;
    // Relaciona a letra de cada filtro com o nome do campo que aparece no JSON.
    const fields = {
      'c': 'strCategory',
      'g': 'strGlass',
      'i': 'strIngredient1',
      'a': 'strAlcoholic',
    };
    // Solicita à API a lista de valores possíveis para o tipo de filtro escolhido.
    final rows = await _get('list.php', {kind: 'list'});
    final values =
        rows
            // Transforma cada item da sequência; a função abaixo define o resultado de cada um.
            .map((row) => apiText(row[fields[kind]]))
            // Mantém somente valores de texto; os null são descartados.
            .whereType<String>()
            // Remove valores repetidos, pois um conjunto não guarda duplicatas.
            .toSet()
            // Materializa os itens transformados em uma lista que pode ser usada pelo Flutter.
            .toList()
          // Ordena a mesma lista alfabeticamente; .. permite agir sobre ela sem substituí-la.
          ..sort();
    // Salva as opções para reutilizar enquanto este serviço estiver vivo.
    _listCache[kind] = values;
    // Entrega as opções à tela que chamou o serviço.
    return values;
  }

  // Busca ingredientes por nome e lê a lista na chave ingredients do JSON.
  Future<List<Ingredient>> searchIngredients(String name) async => (await _get(
    'search.php',
    {'i': name.trim()},
    root: 'ingredients',
  )).map(Ingredient.fromJson).toList();
  // Escolhe um ingrediente entre os resultados da pesquisa pelo nome.
  Future<Ingredient?> ingredientByName(String name) async {
    // Reaproveita a pesquisa de ingredientes para localizar este nome.
    final rows = await searchIngredients(name);
    // Se não existe resultado, devolve null em vez de tentar acessar o primeiro item.
    if (rows.isEmpty) return null;
    // Procura o primeiro ingrediente que satisfaça a comparação abaixo.
    return rows.firstWhere(
      // Compara os nomes em minúsculas para ignorar diferenças entre maiúsculas e minúsculas.
      (item) => item.name.toLowerCase() == name.toLowerCase(),
      // Se não houver nome exatamente igual, usa o primeiro resultado recebido.
      orElse: () => rows.first,
    );
  }

  // Consulta um ingrediente específico pelo identificador iid.
  Future<Ingredient?> ingredientById(String id) async {
    final rows = await _get('lookup.php', {'iid': id}, root: 'ingredients');
    return rows.isEmpty ? null : Ingredient.fromJson(rows.first);
  }

  Future<Drink?> randomDrink() async {
    final rows = await _get('random.php', {});
    return rows.isEmpty ? null : Drink.fromJson(rows.first);
  }

  // Monta o endereço da foto sem fazer a consulta. static permite chamar pela classe.
  static String ingredientImage(String name) =>
      'https://www.thecocktaildb.com/images/ingredients/${Uri.encodeComponent(name)}-medium.png';

  // Libera os recursos do cliente de rede quando o aplicativo não precisar dele.
  void close() => _client.close();
}
