import 'package:flutter/material.dart';

import '../labels_pt.dart';
import '../models/drink.dart';
import '../models/ingredient.dart';
import '../services/cocktail_api.dart';
import '../widgets/shared.dart';
import 'drink_detail_page.dart';

class IngredientDetailPage extends StatefulWidget {
  final CocktailApi api;
  final String name;
  const IngredientDetailPage({
    super.key,
    required this.api,
    required this.name,
  });
  @override
  State<IngredientDetailPage> createState() => _IngredientDetailPageState();
}

class _IngredientDetailPageState extends State<IngredientDetailPage> {
  late Future<Ingredient?> ingredient;
  Future<List<DrinkSummary>>? drinks;
  @override
  void initState() {
    super.initState();
    ingredient = widget.api.ingredientByName(widget.name);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ingrediente')),
    body: PageBody(
      children: [
        heading(widget.name, size: 38),
        const SizedBox(height: 20),
        ApiPhoto(
          CocktailApi.ingredientImage(widget.name),
          height: 240,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        FutureBuilder<Ingredient?>(
          future: ingredient,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return const Busy();
            if (snapshot.hasError)
              return FeedbackBox(
                snapshot.error.toString(),
                retry: () => setState(
                  () => ingredient = widget.api.ingredientByName(widget.name),
                ),
              );
            final item = snapshot.data;
            if (item == null)
              return const FeedbackBox(
                'A API não tem uma descrição deste ingrediente. Você ainda pode consultar os drinks abaixo.',
              );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    if (item.type != null)
                      Chip(label: Text('Tipo: ${labelPt(item.type!)}')),
                    if (item.alcohol != null)
                      Chip(
                        label: Text('Contém álcool: ${labelPt(item.alcohol!)}'),
                      ),
                    if (item.abv != null)
                      Chip(label: Text('Teor alcoólico: ${item.abv}%')),
                  ],
                ),
                const SizedBox(height: 16),
                Text(item.description ?? 'Descrição não informada pela API.'),
                if (item.description != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Descrição no idioma original da API.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () =>
              setState(() => drinks = widget.api.filter('i', widget.name)),
          child: Text('Ver drinks com ${widget.name}'),
        ),
        if (drinks != null) ...[
          const SizedBox(height: 24),
          FutureBuilder<List<DrinkSummary>>(
            future: drinks,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done)
                return const Busy();
              if (snapshot.hasError)
                return FeedbackBox(
                  snapshot.error.toString(),
                  retry: () => setState(
                    () => drinks = widget.api.filter('i', widget.name),
                  ),
                );
              final items = snapshot.data ?? [];
              if (items.isEmpty)
                return const FeedbackBox(
                  'Nenhum drink encontrado com este ingrediente.',
                );
              return DrinkCards(
                drinks: items,
                onOpen: (id) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DrinkDetailPage(api: widget.api, id: id),
                  ),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 32),
      ],
    ),
  );
}
