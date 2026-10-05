// MODELOS DE DRINK: organizam o JSON em resumo, receita e ingrediente com medida.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Os modelos transformam o JSON em objetos que a interface consegue usar.
// A função também normaliza valores nulos e espaços enviados pela API.
String? apiText(Object? value) {
  // Se value não for null, converte em texto e remove espaços nas pontas.
  final text = value?.toString().trim();
  // Se faltar texto, devolve null; caso contrário, devolve o texto limpo.
  return text == null || text.isEmpty ? null : text;
}

// Representa uma linha da receita: nome do ingrediente e quantidade.
class RecipeItem {
  // Guarda o nome. String é texto; final impede trocar este campo após a criação.
  final String name;
  // Medida do ingrediente; pode faltar, por isso o tipo aceita null.
  final String? measure;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const RecipeItem(this.name, this.measure);
}

// O endpoint filter.php retorna apenas estes três campos.
// Representa os dados mínimos necessários para montar um cartão de drink.
class DrinkSummary {
  // Identificador da API mantido como texto, mesmo quando contém apenas números.
  final String id;
  // Guarda o nome. String é texto; final impede trocar este campo após a criação.
  final String name;
  // Endereço da foto; o ? permite que a API não informe imagem.
  final String? image;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const DrinkSummary({required this.id, required this.name, this.image});
  // Construtor de conversão: recebe um mapa da API e cria o objeto deste modelo.
  factory DrinkSummary.fromJson(Map<String, dynamic> json) => DrinkSummary(
    // Lê o campo correspondente no JSON e normaliza o texto para preencher id.
    id: apiText(json['idDrink']) ?? '',
    // Lê o campo correspondente no JSON e normaliza o texto para preencher name.
    name: apiText(json['strDrink']) ?? 'Drink sem nome',
    // Lê o campo correspondente no JSON e normaliza o texto para preencher image.
    image: apiText(json['strDrinkThumb']),
  );
}

// Mesmo quando a busca já retorna a receita completa, a tela de detalhes
// consulta lookup.php: assim ela também funciona para resultados dos filtros.
// Representa uma receita completa, incluindo o resumo e a lista de ingredientes.
class Drink {
  // Agrupa ID, nome e foto do drink dentro da receita completa.
  final DrinkSummary summary;
  // Campos opcionais: categoria, copo, álcool, preparo e crédito da foto.
  final String? category, glass, alcohol, instructions, attribution;
  // Lista dos ingredientes da receita, cada um ligado à sua própria medida.
  final List<RecipeItem> ingredients;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const Drink({
    // Parâmetro obrigatório: guarda no campo de mesmo nome o valor recebido.
    required this.summary,
    this.category,
    this.glass,
    this.alcohol,
    this.instructions,
    this.attribution,
    // Parâmetro obrigatório: guarda no campo de mesmo nome o valor recebido.
    required this.ingredients,
  });
  // Construtor de conversão: recebe um mapa da API e cria o objeto deste modelo.
  factory Drink.fromJson(Map<String, dynamic> json) {
    // Começa uma lista vazia que só poderá receber objetos RecipeItem.
    final items = <RecipeItem>[];
    // Percorre os 15 espaços de ingredientes da API, começando em 1 e somando 1.
    for (var i = 1; i <= 15; i++) {
      // Monta a chave com o índice: strIngredient1, strIngredient2 e assim por diante.
      final name = apiText(json['strIngredient$i']);
      // Ingrediente e medida são lidos do MESMO índice, mesmo com lacunas.
      // Só acrescenta o ingrediente quando existe um nome válido nesta posição.
      if (name != null)
        items.add(RecipeItem(name, apiText(json['strMeasure$i'])));
    }
    return Drink(
      summary: DrinkSummary.fromJson(json),
      // Lê o campo correspondente no JSON e normaliza o texto para preencher category.
      category: apiText(json['strCategory']),
      // Lê o campo correspondente no JSON e normaliza o texto para preencher glass.
      glass: apiText(json['strGlass']),
      // Lê o campo correspondente no JSON e normaliza o texto para preencher alcohol.
      alcohol: apiText(json['strAlcoholic']),
      // Lê o campo correspondente no JSON e normaliza o texto para preencher instructions.
      instructions: apiText(json['strInstructions']),
      // Lê o campo correspondente no JSON e normaliza o texto para preencher attribution.
      attribution: apiText(json['strImageAttribution']),
      // Entrega à receita a lista montada no laço acima.
      ingredients: items,
    );
  }
}
