import 'package:flutter/material.dart';

import '../models/drink.dart';
import '../services/cocktail_api.dart';
import '../widgets/shared.dart';
import 'drink_detail_page.dart';

class DiscoverPage extends StatefulWidget {
  final CocktailApi api;

  const DiscoverPage({super.key, required this.api});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final List<String> selectedIngredients = [];
  Future<List<DrinkSummary>>? results;

  Future<void> _addIngredient() async {
    final ingredients = await widget.api.listValues('i');

    if (!mounted) return;

    final available = ingredients
        .where((name) => !selectedIngredients.contains(name))
        .toList();

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: available
              .map(
                (name) => ListTile(
                  title: Text(name),
                  onTap: () => Navigator.pop(context, name),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() => selectedIngredients.add(selected));
    }
  }

  void _findDrinks() {
    if (selectedIngredients.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha pelo menos dois ingredientes.')),
      );
      return;
    }

    setState(() {
      results = widget.api.filterByIngredients(selectedIngredients);
    });
  }

  void _premiumMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta opção exige uma chave Premium da TheCocktailDB.'),
      ),
    );
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
        heading('Mais combinações, novas escolhas.', size: 32),
        const SizedBox(height: 8),
        const Text(
          'Recursos disponíveis com uma chave Premium da TheCocktailDB.',
        ),
        const SizedBox(height: 18),

        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: const Text('Populares'),
              onPressed: _premiumMessage,
            ),
            ActionChip(
              label: const Text('Recentes'),
              onPressed: _premiumMessage,
            ),
            ActionChip(
              label: const Text('10 aleatórios'),
              onPressed: _premiumMessage,
            ),
          ],
        ),

        const SizedBox(height: 28),
        heading('O que você tem por aí?', size: 24),
        const SizedBox(height: 8),
        const Text(
          'Combine ingredientes para encontrar receitas que usem todos eles.',
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedIngredients.map(
              (name) => InputChip(
                label: Text(name),
                onDeleted: () {
                  setState(() => selectedIngredients.remove(name));
                },
              ),
            ),
            ActionChip(
              label: const Text('+ Ingrediente'),
              onPressed: _addIngredient,
            ),
            FilledButton(
              onPressed: _findDrinks,
              child: const Text('Encontrar'),
            ),
          ],
        ),

        const SizedBox(height: 28),
        if (results != null) ...[
          const Divider(),
          const SizedBox(height: 16),
          heading('Drinks da sua combinação', size: 24),
          const SizedBox(height: 16),
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
                  'Não encontramos drinks com todos esses ingredientes.',
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
