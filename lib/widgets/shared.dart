// PEÇAS REUTILIZÁVEIS: títulos, fotos, cartões, espaçamentos e mensagens das telas.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Importa os componentes visuais: telas, botões, campos, ícones e cores.
import 'package:flutter/material.dart';

// Importa os modelos que organizam os dados recebidos da API.
import '../models/drink.dart';

// Laranja da marca. Em 0xAARRGGBB, FF significa cor totalmente opaca.
const orange = Color(0xFFD85920);
// Cor escura usada nos textos principais.
const ink = Color(0xFF30291F);
// Tom claro de pêssego usado no destaque inicial e nos espaços de imagem.
const peach = Color(0xFFFFF0E5);

Widget heading(String text, {double size = 30}) => Text(
  text,
  style: TextStyle(
    // Escolhe a família da fonte para o texto.
    fontFamily: 'Georgia',
    fontFamilyFallback: const ['serif'],
    // Define o tamanho da fonte em unidades lógicas do Flutter.
    fontSize: size,
    color: ink,
    height: 1.15,
  ),
);

// Limita a largura no computador; no celular usa o espaço disponível.
// Define uma peça visual que recebe dados, mas não mantém um State próprio.
class PageBody extends StatelessWidget {
  // Lista de componentes que este corpo de página vai colocar na tela.
  final List<Widget> children;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const PageBody({super.key, required this.children});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => SingleChildScrollView(
    // Define o espaço interno entre o conteúdo e suas bordas.
    padding: const EdgeInsets.all(24),
    // Define o único componente filho que ocupa este espaço.
    child: Center(
      // Define o único componente filho que ocupa este espaço.
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        // Define o único componente filho que ocupa este espaço.
        child: Column(
          // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
          crossAxisAlignment: CrossAxisAlignment.start,
          // Lista os componentes filhos que serão desenhados dentro deste componente.
          children: children,
        ),
      ),
    ),
  );
}

// Define uma peça visual que recebe dados, mas não mantém um State próprio.
class ApiPhoto extends StatelessWidget {
  final String? url;
  final double height;
  final BoxFit fit;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const ApiPhoto(
    this.url, {
    // Repassa ao Flutter uma identificação opcional usada para reconhecer o componente.
    super.key,
    this.height = 180,
    this.fit = BoxFit.cover,
  });
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) {
    // Desenho provisório usado enquanto a imagem carrega ou quando ela falta/falha.
    final placeholder = Container(
      height: height,
      color: peach,
      alignment: Alignment.center,
      // Define o único componente filho que ocupa este espaço.
      child: const Icon(Icons.local_bar, color: orange, size: 40),
    );
    return ClipRRect(
      // Arredonda os cantos sem mudar a função do componente.
      borderRadius: BorderRadius.circular(20),
      // Define o único componente filho que ocupa este espaço.
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              height: height,
              // Pede toda a largura que o componente pai permitir.
              width: double.infinity,
              fit: fit,
              // Se a foto não carregar, usa o desenho provisório em vez de mostrar uma falha.
              errorBuilder: (_, error, stack) => placeholder,
              // Acompanha o carregamento: child é a imagem e progress indica que ainda há download.
              loadingBuilder: (_, child, progress) =>
                  // Quando não há progresso pendente, mostra a foto; até lá, mostra o provisório.
                  progress == null ? child : placeholder,
            ),
    );
  }
}

// Define uma peça visual que recebe dados, mas não mantém um State próprio.
class FeedbackBox extends StatelessWidget {
  final String text;
  // Função opcional para tentar novamente; VoidCallback não recebe nem devolve dados.
  final VoidCallback? retry;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const FeedbackBox(this.text, {super.key, this.retry});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => Padding(
    // Define o espaço interno entre o conteúdo e suas bordas.
    padding: const EdgeInsets.symmetric(vertical: 32),
    // Define o único componente filho que ocupa este espaço.
    child: Column(
      // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
      crossAxisAlignment: CrossAxisAlignment.start,
      // Lista os componentes filhos que serão desenhados dentro deste componente.
      children: [
        Text(text),
        if (retry != null)
          Padding(
            // Define o espaço interno entre o conteúdo e suas bordas.
            padding: const EdgeInsets.only(top: 12),
            // Define o único componente filho que ocupa este espaço.
            child: OutlinedButton(
              // Ação executada ao clicar ou tocar no botão; a função não roda na montagem da tela.
              onPressed: retry,
              // Define o único componente filho que ocupa este espaço.
              child: const Text('Tentar novamente'),
            ),
          ),
      ],
    ),
  );
}

// Define uma peça visual que recebe dados, mas não mantém um State próprio.
class Busy extends StatelessWidget {
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const Busy({super.key});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => const Padding(
    // Define o espaço interno entre o conteúdo e suas bordas.
    padding: EdgeInsets.all(32),
    // Define o único componente filho que ocupa este espaço.
    child: Center(
      // Define o único componente filho que ocupa este espaço.
      child: Column(
        // Lista os componentes filhos que serão desenhados dentro deste componente.
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
// Define uma peça visual que recebe dados, mas não mantém um State próprio.
class DrinkCards extends StatelessWidget {
  final List<DrinkSummary> drinks;
  // Função recebida de outra tela; será chamada com o ID do cartão tocado.
  final ValueChanged<String> onOpen;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const DrinkCards({super.key, required this.drinks, required this.onOpen});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => LayoutBuilder(
    // constraints informa o espaço disponível para decidir a disposição dos elementos.
    builder: (context, constraints) {
      // Escolhe 3 colunas em tela larga, 2 em média e 1 em tela estreita.
      final columns = constraints.maxWidth > 850
          ? 3
          : constraints.maxWidth > 500
          ? 2
          : 1;
      // Desconta os espaços entre cartões e divide o restante igualmente entre as colunas.
      final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
      return Wrap(
        // Define a distância entre elementos na mesma linha do Wrap.
        spacing: 20,
        // Define a distância entre as linhas quando o Wrap quebra o conteúdo.
        runSpacing: 24,
        // Lista os componentes filhos que serão desenhados dentro deste componente.
        children: drinks
            // Transforma cada item da sequência; a função abaixo define o resultado de cada um.
            .map(
              (drink) => SizedBox(
                width: width,
                // Define o único componente filho que ocupa este espaço.
                child: InkWell(
                  // Arredonda os cantos sem mudar a função do componente.
                  borderRadius: BorderRadius.circular(20),
                  // Ação executada ao tocar neste elemento, como abrir um cartão.
                  onTap: () => onOpen(drink.id),
                  // Define o único componente filho que ocupa este espaço.
                  child: Column(
                    // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Lista os componentes filhos que serão desenhados dentro deste componente.
                    children: [
                      ApiPhoto(drink.image),
                      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                      const SizedBox(height: 10),
                      Row(
                        // Lista os componentes filhos que serão desenhados dentro deste componente.
                        children: [
                          Expanded(child: heading(drink.name, size: 24)),
                          // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                          const Icon(Icons.arrow_forward, color: orange),
                        ],
                      ),
                      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                      const SizedBox(height: 4),
                      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                      const Text('Ver ingredientes e preparo'),
                    ],
                  ),
                ),
              ),
            )
            // Materializa os itens transformados em uma lista que pode ser usada pelo Flutter.
            .toList(),
      );
    },
  );
}
