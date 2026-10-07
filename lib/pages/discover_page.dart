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
  late Future<Drink?> surprise;

  @override
  void initState() {
    super.initState();
    surprise = widget.api.randomDrink();
  }

  void _sortearOutra() {
    setState(() {
      surprise = widget.api.randomDrink();
    });
  }

  void _abrirReceita(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrinkDetailPage(api: widget.api, id: id),
      ),
    );
  }

  Widget _cartaoSurpresa(Drink drink, double width) {
    final imagem = ApiPhoto(drink.summary.image, height: 220);

    final detalhes = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'SUA RECEITA SURPRESA',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        heading(drink.summary.name, size: 36),
        const SizedBox(height: 8),
        const Text(
          'Veja os ingredientes, conheça o preparo e experimente uma nova combinação.',
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: () => _abrirReceita(drink.summary.id),
              child: const Text('Ver receita'),
            ),
            OutlinedButton(
              onPressed: _sortearOutra,
              child: const Text('Sortear outra'),
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: peach,
        borderRadius: BorderRadius.circular(22),
      ),
      child: width >= 600
          ? Row(
              children: [
                Expanded(child: imagem),
                const SizedBox(width: 28),
                Expanded(child: detalhes),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [imagem, const SizedBox(height: 18), detalhes],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        heading('Hoje, deixe a escolha com a gente.', size: 32),
        const SizedBox(height: 20),
        FutureBuilder<Drink?>(
          future: surprise,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(height: 280, child: Busy());
            }

            if (snapshot.hasError) {
              return FeedbackBox(
                snapshot.error.toString(),
                retry: _sortearOutra,
              );
            }

            final drink = snapshot.data;

            if (drink == null) {
              return FeedbackBox(
                'Não foi possível sortear um drink.',
                retry: _sortearOutra,
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return _cartaoSurpresa(drink, constraints.maxWidth);
              },
            );
          },
        ),
        const SizedBox(height: 32),
        const Divider(),
        const Text('Receitas e fotos: TheCocktailDB'),
      ],
    );
  }
}
