import 'drink.dart';

class Ingredient {
  final String id, name;
  final String? description, type, alcohol, abv;
  const Ingredient({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.alcohol,
    this.abv,
  });
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: apiText(json['idIngredient']) ?? '',
    name: apiText(json['strIngredient']) ?? 'Ingrediente sem nome',
    description: apiText(json['strDescription']),
    type: apiText(json['strType']),
    alcohol: apiText(json['strAlcohol']),
    abv: apiText(json['strABV']),
  );
}
