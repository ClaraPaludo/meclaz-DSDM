import 'package:flutter/material.dart';

import '../models/drink.dart';

const orange = Color(0xFFD85920);
const ink = Color(0xFF30291F);
const peach = Color(0xFFFFF0E5);

Widget heading(String text, {double size = 30}) => Text(
  text,
  style: TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: const ['serif'],
    fontSize: size,
    color: ink,
    height: 1.15,
  ),
);

// Limita a largura no computador; no celular usa o espaço disponível.
class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ),
  );
}

class ApiPhoto extends StatelessWidget {
  final String? url;
  final double height;
  final BoxFit fit;
  const ApiPhoto(
    this.url, {
    super.key,
    this.height = 180,
    this.fit = BoxFit.cover,
  });
  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      color: peach,
      alignment: Alignment.center,
      child: const Icon(Icons.local_bar, color: orange, size: 40),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              height: height,
              width: double.infinity,
              fit: fit,
              errorBuilder: (_, error, stack) => placeholder,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : placeholder,
            ),
    );
  }
}

class FeedbackBox extends StatelessWidget {
  final String text;
  final VoidCallback? retry;
  const FeedbackBox(this.text, {super.key, this.retry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text),
        if (retry != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton(
              onPressed: retry,
              child: const Text('Tentar novamente'),
            ),
          ),
      ],
    ),
  );
}

class Busy extends StatelessWidget {
  const Busy({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(32),
    child: Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Buscando na API…'),
        ],
      ),
    ),
  );
}

// Wrap permite que os cartões se reorganizem sem largura fixa de tela.
class DrinkCards extends StatelessWidget {
  final List<DrinkSummary> drinks;
  final ValueChanged<String> onOpen;
  const DrinkCards({super.key, required this.drinks, required this.onOpen});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth > 850
          ? 3
          : constraints.maxWidth > 500
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
      return Wrap(
        spacing: 20,
        runSpacing: 24,
        children: drinks
            .map(
              (drink) => SizedBox(
                width: width,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onOpen(drink.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ApiPhoto(drink.image),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: heading(drink.name, size: 24)),
                          const Icon(Icons.arrow_forward, color: orange),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Ver ingredientes e preparo'),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}
