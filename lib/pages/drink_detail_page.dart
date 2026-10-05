import 'package:flutter/material.dart';

import '../labels_pt.dart';
import '../models/drink.dart';
import '../services/cocktail_api.dart';
import '../widgets/shared.dart';
import 'ingredient_detail_page.dart';

class DrinkDetailPage extends StatefulWidget {
  final CocktailApi api;
  final String id;
  const DrinkDetailPage({super.key, required this.api, required this.id});
  @override
  State<DrinkDetailPage> createState() => _DrinkDetailPageState();
}

class _DrinkDetailPageState extends State<DrinkDetailPage> {
  late Future<Drink?> recipe;
  @override
  void initState() {
    super.initState();
    recipe = widget.api.drinkById(widget.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Receita')),
    body: FutureBuilder<Drink?>(
      future: recipe,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return const Busy();
        if (snapshot.hasError)
          return PageBody(
            children: [
              FeedbackBox(
                snapshot.error.toString(),
                retry: () =>
                    setState(() => recipe = widget.api.drinkById(widget.id)),
              ),
            ],
          );
        final drink = snapshot.data;
        if (drink == null)
          return const PageBody(
            children: [FeedbackBox('Receita não encontrada.')],
          );
        final ingredients = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading(drink.summary.name, size: 38),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [drink.category, drink.alcohol, drink.glass]
                  .whereType<String>()
                  .map((text) => Chip(label: Text(labelPt(text))))
                  .toList(),
            ),
            const SizedBox(height: 24),
            heading('Ingredientes', size: 26),
            if (drink.ingredients.isEmpty)
              const Text('Ingredientes não informados.'),
            ...drink.ingredients.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                subtitle: Text(item.measure ?? 'Medida não informada'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        IngredientDetailPage(api: widget.api, name: item.name),
                  ),
                ),
              ),
            ),
          ],
        );
        return PageBody(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth > 750
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ApiPhoto(drink.summary.image, height: 440),
                        ),
                        const SizedBox(width: 32),
                        Expanded(child: ingredients),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ApiPhoto(drink.summary.image, height: 300),
                        const SizedBox(height: 24),
                        ingredients,
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            heading('Modo de preparo'),
            const SizedBox(height: 12),
            Text(drink.instructions ?? 'Modo de preparo não informado.'),
            const SizedBox(height: 16),
            const Text(
              'Texto original da API. A TheCocktailDB não fornece o preparo em português.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Divider(),
            Text(
              drink.attribution == null
                  ? 'Receita e foto: TheCocktailDB'
                  : 'Receita: TheCocktailDB • Foto: ${drink.attribution}',
            ),
          ],
        );
      },
    ),
  );
}
