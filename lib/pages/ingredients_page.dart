import 'package:flutter/material.dart';

import '../services/cocktail_api.dart';
import '../widgets/shared.dart';
import 'ingredient_detail_page.dart';

class IngredientsPage extends StatefulWidget {
  final CocktailApi api;
  const IngredientsPage({super.key, required this.api});
  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final search = TextEditingController();
  late Future<List<String>> results;
  String term = '';
  @override
  void initState() {
    super.initState();
    results = widget.api.listValues('i');
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _load() => setState(() {
    term = search.text.trim();
    // Campo vazio mostra o catálogo; texto usa a busca de ingredientes da API.
    results = term.isEmpty
        ? widget.api.listValues('i')
        : widget.api
              .searchIngredients(term)
              .then((items) => items.map((e) => e.name).toList());
  });
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      heading('Tudo começa com\num ingrediente.', size: 38),
      const SizedBox(height: 16),
      const Text('Conheça os ingredientes e encontre drinks que usam cada um.'),
      const SizedBox(height: 24),
      TextField(
        controller: search,
        onSubmitted: (_) => _load(),
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          labelText: 'Nome do ingrediente na API, por exemplo: Gin',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        children: [
          FilledButton(
            onPressed: _load,
            child: const Text('Buscar ingrediente'),
          ),
          TextButton(
            onPressed: () {
              search.clear();
              _load();
            },
            child: const Text('Ver todos'),
          ),
        ],
      ),
      const SizedBox(height: 24),
      FutureBuilder<List<String>>(
        future: results,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const Busy();
          if (snapshot.hasError)
            return FeedbackBox(snapshot.error.toString(), retry: _load);
          final items = snapshot.data ?? [];
          if (items.isEmpty)
            return const FeedbackBox(
              'Nenhum ingrediente encontrado. Tente o nome usado pela API, como Tequila.',
            );
          // A lista pode ser grande. Os blocos de texto são leves; fotos ficam
          // na página de detalhe para não baixar centenas de imagens de uma vez.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${items.length} ingredientes'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: items
                    .map(
                      (name) => ActionChip(
                        avatar: const Icon(Icons.eco_outlined, size: 18),
                        label: Text(name),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IngredientDetailPage(
                              api: widget.api,
                              name: name,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 32),
    ],
  );
}
