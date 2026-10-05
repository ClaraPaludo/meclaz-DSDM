// Os modelos transformam o JSON em objetos que a interface consegue usar.
// A função também normaliza valores nulos e espaços enviados pela API.
String? apiText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

class RecipeItem {
  final String name;
  final String? measure;
  const RecipeItem(this.name, this.measure);
}

// O endpoint filter.php retorna apenas estes três campos.
class DrinkSummary {
  final String id;
  final String name;
  final String? image;
  const DrinkSummary({required this.id, required this.name, this.image});
  factory DrinkSummary.fromJson(Map<String, dynamic> json) => DrinkSummary(
    id: apiText(json['idDrink']) ?? '',
    name: apiText(json['strDrink']) ?? 'Drink sem nome',
    image: apiText(json['strDrinkThumb']),
  );
}

// Mesmo quando a busca já retorna a receita completa, a tela de detalhes
// consulta lookup.php: assim ela também funciona para resultados dos filtros.
class Drink {
  final DrinkSummary summary;
  final String? category, glass, alcohol, instructions, attribution;
  final List<RecipeItem> ingredients;
  const Drink({
    required this.summary,
    this.category,
    this.glass,
    this.alcohol,
    this.instructions,
    this.attribution,
    required this.ingredients,
  });
  factory Drink.fromJson(Map<String, dynamic> json) {
    final items = <RecipeItem>[];
    for (var i = 1; i <= 15; i++) {
      final name = apiText(json['strIngredient$i']);
      // Ingrediente e medida são lidos do MESMO índice, mesmo com lacunas.
      if (name != null)
        items.add(RecipeItem(name, apiText(json['strMeasure$i'])));
    }
    return Drink(
      summary: DrinkSummary.fromJson(json),
      category: apiText(json['strCategory']),
      glass: apiText(json['strGlass']),
      alcohol: apiText(json['strAlcoholic']),
      instructions: apiText(json['strInstructions']),
      attribution: apiText(json['strImageAttribution']),
      ingredients: items,
    );
  }
}
