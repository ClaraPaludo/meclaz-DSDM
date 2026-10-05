import 'package:flutter/material.dart';

import '../labels_pt.dart';
import '../models/drink.dart';
import '../services/cocktail_api.dart';
import '../widgets/shared.dart';
import 'drink_detail_page.dart';

class DrinksPage extends StatefulWidget {
  final CocktailApi api;
  const DrinksPage({super.key, required this.api});
  @override
  State<DrinksPage> createState() => _DrinksPageState();
}

class _DrinksPageState extends State<DrinksPage> {
  final search = TextEditingController();
  List<DrinkSummary> drinks = [];
  bool loading = true;
  String? error;
  String title = 'Para começar • letra A';
  String kind = 'c';
  String? value;
  late Future<List<String>> options;
  late Future<List<DrinkSummary>> Function() lastQuery;
  int request = 0;

  @override
  void initState() {
    super.initState();
    options = widget.api.listValues(kind);
    _load(() => widget.api.searchByLetter('a'));
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _load(Future<List<DrinkSummary>> Function() query) async {
    lastQuery = query;
    final ticket = ++request;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await query();
      // Se outra pesquisa terminou antes, esta resposta antiga é ignorada.
      if (!mounted || ticket != request) return;
      setState(() {
        drinks = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted || ticket != request) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void _search() {
    final term = search.text.trim();
    if (term.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome de um drink.')),
      );
      return;
    }
    setState(() {
      value = null;
      title = 'Resultados para “$term”';
    });
    _load(() => widget.api.searchByName(term));
  }

  void _open(String id) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DrinkDetailPage(api: widget.api, id: id),
    ),
  );

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: peach,
          borderRadius: BorderRadius.circular(26),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final intro = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading(
                  'Qual vai ser o\ndrink de hoje?',
                  size: constraints.maxWidth < 500 ? 34 : 44,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Uma receita conhecida ou uma nova combinação.\nEncontre a sua próxima escolha.',
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    labelText: 'Busque um drink pelo nome',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _search, child: const Text('Buscar')),
              ],
            );
            // A foto vem do resultado da API, sem receita ou imagem fixa no código.
            return constraints.maxWidth > 750 && drinks.isNotEmpty
                ? Row(
                    children: [
                      Expanded(child: intro),
                      const SizedBox(width: 30),
                      SizedBox(
                        width: 300,
                        child: ApiPhoto(drinks.first.image, height: 280),
                      ),
                    ],
                  )
                : intro;
          },
        ),
      ),
      const SizedBox(height: 28),
      heading('Encontre pelo seu estilo'),
      const SizedBox(height: 12),
      const Text(
        'Escolha um filtro por vez. Uma nova busca substitui o filtro anterior.',
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        initialValue: kind,
        decoration: const InputDecoration(labelText: 'Filtrar por'),
        items: const [
          DropdownMenuItem(value: 'c', child: Text('Categoria')),
          DropdownMenuItem(value: 'a', child: Text('Presença de álcool')),
          DropdownMenuItem(value: 'g', child: Text('Tipo de copo')),
          DropdownMenuItem(value: 'i', child: Text('Ingrediente')),
        ],
        onChanged: (next) {
          if (next != null)
            setState(() {
              kind = next;
              value = null;
              options = widget.api.listValues(kind);
            });
        },
      ),
      const SizedBox(height: 12),
      FutureBuilder<List<String>>(
        future: options,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const LinearProgressIndicator();
          if (snapshot.hasError)
            return FeedbackBox(
              'Não foi possível carregar os filtros.',
              retry: () =>
                  setState(() => options = widget.api.listValues(kind)),
            );
          final values = snapshot.data ?? [];
          if (values.isEmpty)
            return const FeedbackBox('A API não retornou opções de filtro.');
          return DropdownButtonFormField<String>(
            key: ValueKey('$kind:$value'),
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Selecione uma opção'),
            items: values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(labelPt(item), overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (next) {
              if (next == null) return;
              final selectedKind = kind;
              setState(() {
                value = next;
                search.clear();
                title = labelPt(next);
              });
              _load(() => widget.api.filter(selectedKind, next));
            },
          );
        },
      ),
      const SizedBox(height: 24),
      const Text('Ou explore pela primeira letra'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 4,
        runSpacing: 4,
        children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            .split('')
            .map(
              (letter) => TextButton(
                onPressed: () {
                  setState(() {
                    value = null;
                    search.clear();
                    title = 'Drinks com a letra $letter';
                  });
                  _load(() => widget.api.searchByLetter(letter.toLowerCase()));
                },
                child: Text(letter),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 24),
      heading(title),
      const SizedBox(height: 18),
      if (loading)
        const Busy()
      else if (error != null)
        FeedbackBox(error!, retry: () => _load(lastQuery))
      else if (drinks.isEmpty)
        const FeedbackBox(
          'Nenhum drink encontrado. Tente outro nome, letra ou filtro.',
        )
      else
        DrinkCards(drinks: drinks, onOpen: _open),
      const SizedBox(height: 40),
      const Divider(),
      const Text('Receitas e fotos: TheCocktailDB'),
      const SizedBox(height: 12),
    ],
  );
}
