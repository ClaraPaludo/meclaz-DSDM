import 'package:flutter/material.dart';

import '../services/cocktail_api.dart';
import '../widgets/shared.dart';
import 'drinks_page.dart';
import 'ingredients_page.dart';

class HomePage extends StatefulWidget {
  final CocktailApi api;
  const HomePage({super.key, required this.api});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'zest.',
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 32,
          color: orange,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => tab = 0),
          child: Text(
            'Drinks',
            style: TextStyle(
              fontWeight: tab == 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => tab = 1),
          child: Text(
            'Ingredientes',
            style: TextStyle(
              fontWeight: tab == 1 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    ),
    // IndexedStack preserva a pesquisa quando o usuário muda de aba.
    body: IndexedStack(
      index: tab,
      children: [
        DrinksPage(api: widget.api),
        IngredientsPage(api: widget.api),
      ],
    ),
  );
}
