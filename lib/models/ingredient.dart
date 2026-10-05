// MODELO DE INGREDIENTE: guarda os dados recebidos sobre um ingrediente.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

import 'drink.dart';

// Representa os detalhes de um único ingrediente retornado pela API.
class Ingredient {
  // Dois campos de texto: o identificador e o nome do ingrediente.
  final String id, name;
  // Descrição, tipo, presença de álcool e teor alcoólico; todos podem estar ausentes.
  final String? description, type, alcohol, abv;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const Ingredient({
    // Parâmetro obrigatório: guarda no campo de mesmo nome o valor recebido.
    required this.id,
    // Parâmetro obrigatório: guarda no campo de mesmo nome o valor recebido.
    required this.name,
    this.description,
    this.type,
    this.alcohol,
    this.abv,
  });
  // Construtor de conversão: recebe um mapa da API e cria o objeto deste modelo.
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    // Lê o campo correspondente no JSON e normaliza o texto para preencher id.
    id: apiText(json['idIngredient']) ?? '',
    // Lê o campo correspondente no JSON e normaliza o texto para preencher name.
    name: apiText(json['strIngredient']) ?? 'Ingrediente sem nome',
    // Lê o campo correspondente no JSON e normaliza o texto para preencher description.
    description: apiText(json['strDescription']),
    // Lê o campo correspondente no JSON e normaliza o texto para preencher type.
    type: apiText(json['strType']),
    // Lê o campo correspondente no JSON e normaliza o texto para preencher alcohol.
    alcohol: apiText(json['strAlcohol']),
    // Lê o campo correspondente no JSON e normaliza o texto para preencher abv.
    abv: apiText(json['strABV']),
  );
}
