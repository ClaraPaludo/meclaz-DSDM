import 'package:flutter/material.dart';

import '../models/drink.dart';
import '../services/cocktail_api.dart';
import '../widgets/shared.dart';
import 'drink_detail_page.dart';

class IngredientMixPage extends StatefulWidget {
  final CocktailApi api;

  const IngredientMixPage({super.key, required this.api});

  @override
  State<IngredientMixPage> createState() => _IngredientMixPageState();
}

class _IngredientMixPageState extends State<IngredientMixPage> {
  late Future<List<String>> ingredientOptions;
  final List<String> selectedIngredients = [];

  String? selectedIngredient;
  Future<List<DrinkSummary>>? results;

  @override
  void initState() {
    super.initState();
    ingredientOptions = widget.api.listValues('i');
  }

  void _addIngredient() {
    final name = selectedIngredient;

    if (name == null || selectedIngredients.contains(name)) return;

    setState(() {
      selectedIngredients.add(name);
      results = null;
    });
  }

  Future<void> _chooseIngredient(List<String> options) async {
    final available = options
        .where((name) => !selectedIngredients.contains(name))
        .toList();

    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Escolha um ingrediente',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final option = available[index];
                    return ListTile(
                      title: Text(option),
                      onTap: () => Navigator.pop(sheetContext, option),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (name != null && mounted) {
      setState(() => selectedIngredient = name);
    }
  }

  void _findDrinks() {
    if (selectedIngredients.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos dois ingredientes.')),
      );
      return;
    }

    setState(() {
      results = widget.api.filterByIngredients(selectedIngredients);
    });
  }

  void _openDrink(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrinkDetailPage(api: widget.api, id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        heading('Combine ingredientes', size: 30),
        const SizedBox(height: 8),
        const Text(
          'Escolha dois ou mais ingredientes para encontrar drinks que usem todos eles.',
        ),
        const SizedBox(height: 20),

        FutureBuilder<List<String>>(
          future: ingredientOptions,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Busy();
            }

            if (snapshot.hasError) {
              return FeedbackBox(
                snapshot.error.toString(),
                retry: () {
                  setState(() {
                    ingredientOptions = widget.api.listValues('i');
                  });
                },
              );
            }

            final options = snapshot.data ?? [];

            if (options.isEmpty) {
              return const FeedbackBox(
                'A API não retornou opções de ingredientes.',
              );
            }

            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: options.isEmpty
                        ? null
                        : () => _chooseIngredient(options),
                    icon: const Icon(Icons.search),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedIngredient ?? 'Escolha um ingrediente',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Adicionar ingrediente',
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedIngredients
              .map(
                (name) => InputChip(
                  label: Text(name),
                  onDeleted: () {
                    setState(() {
                      selectedIngredients.remove(name);
                      results = null;
                    });
                  },
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: selectedIngredients.length >= 2 ? _findDrinks : null,
          child: const Text('Encontrar drinks'),
        ),

        if (results != null) ...[
          const SizedBox(height: 24),
          heading('Drinks encontrados', size: 24),
          const SizedBox(height: 12),

          FutureBuilder<List<DrinkSummary>>(
            future: results,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Busy();
              }

              if (snapshot.hasError) {
                return FeedbackBox(snapshot.error.toString());
              }

              final drinks = snapshot.data ?? [];

              if (drinks.isEmpty) {
                return const FeedbackBox(
                  'Não encontramos drinks que usem todos esses ingredientes.',
                );
              }

              return DrinkCards(drinks: drinks, onOpen: _openDrink);
            },
          ),
        ],
      ],
    );
  }
}
