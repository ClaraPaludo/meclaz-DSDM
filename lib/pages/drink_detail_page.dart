// RECEITA COMPLETA: consulta um drink pelo ID e apresenta ingredientes e preparo.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Importa os componentes visuais: telas, botões, campos, ícones e cores.
import 'package:flutter/material.dart';

// Permite mostrar traduções dos rótulos conhecidos.
import '../labels_pt.dart';
// Importa os modelos que organizam os dados recebidos da API.
import '../models/drink.dart';
// Importa o serviço responsável por consultar a TheCocktailDB.
import '../services/cocktail_api.dart';
// Reutiliza os componentes e cores definidos em shared.dart.
import '../widgets/shared.dart';
// Disponibiliza esta página para abri-la a partir deste arquivo.
import 'ingredient_detail_page.dart';

// Define um componente com estado: seus dados podem mudar durante o uso.
class DrinkDetailPage extends StatefulWidget {
  // Recebe o serviço da API de quem criou a tela; evita criar clientes novos a cada página.
  final CocktailApi api;
  // Identificador da API mantido como texto, mesmo quando contém apenas números.
  final String id;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const DrinkDetailPage({super.key, required this.api, required this.id});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Cria o objeto State que vai guardar os dados variáveis deste componente.
  State<DrinkDetailPage> createState() => _DrinkDetailPageState();
}

// Guarda os dados que mudam e as ações do componente associado a este State.
class _DrinkDetailPageState extends State<DrinkDetailPage> {
  // Consulta pendente da receita. O resultado pode ser null se o ID não existir.
  late Future<Drink?> recipe;
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Executa a preparação uma única vez quando este estado é criado.
  void initState() {
    // Executa também a inicialização que o próprio Flutter precisa fazer.
    super.initState();
    // Usa o ID recebido pela página para buscar todos os detalhes do drink.
    recipe = widget.api.drinkById(widget.id);
  }

  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Receita')),
    body: FutureBuilder<Drink?>(
      // Indica qual consulta assíncrona o FutureBuilder deve acompanhar.
      future: recipe,
      // snapshot reúne o estado da consulta, os dados recebidos e um possível erro.
      builder: (context, snapshot) {
        // Enquanto a consulta não terminou, mostra o componente de espera logo abaixo.
        if (snapshot.connectionState != ConnectionState.done)
          return const Busy();
        // Se a consulta falhou, usa a mensagem de erro e a opção de nova tentativa.
        if (snapshot.hasError)
          return PageBody(
            // Lista os componentes filhos que serão desenhados dentro deste componente.
            children: [
              FeedbackBox(
                snapshot.error.toString(),
                // Função chamada pelo botão Tentar novamente quando houve uma falha.
                retry: () =>
                    // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
                    setState(() => recipe = widget.api.drinkById(widget.id)),
              ),
            ],
          );
        // Retira a receita da resposta acompanhada pelo FutureBuilder.
        final drink = snapshot.data;
        if (drink == null)
          return const PageBody(
            // Lista os componentes filhos que serão desenhados dentro deste componente.
            children: [FeedbackBox('Receita não encontrada.')],
          );
        final ingredients = Column(
          // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
          crossAxisAlignment: CrossAxisAlignment.start,
          // Lista os componentes filhos que serão desenhados dentro deste componente.
          children: [
            heading(drink.summary.name, size: 38),
            // Construtor: recebe os dados deste componente. const permite instâncias constantes.
            const SizedBox(height: 16),
            Wrap(
              // Define a distância entre elementos na mesma linha do Wrap.
              spacing: 8,
              // Define a distância entre as linhas quando o Wrap quebra o conteúdo.
              runSpacing: 8,
              // Lista os componentes filhos que serão desenhados dentro deste componente.
              children: [drink.category, drink.alcohol, drink.glass]
                  // Mantém somente valores de texto; os null são descartados.
                  .whereType<String>()
                  // Transforma cada item da sequência; a função abaixo define o resultado de cada um.
                  .map((text) => Chip(label: Text(labelPt(text))))
                  // Materializa os itens transformados em uma lista que pode ser usada pelo Flutter.
                  .toList(),
            ),
            // Construtor: recebe os dados deste componente. const permite instâncias constantes.
            const SizedBox(height: 24),
            heading('Ingredientes', size: 26),
            if (drink.ingredients.isEmpty)
              // Construtor: recebe os dados deste componente. const permite instâncias constantes.
              const Text('Ingredientes não informados.'),
            // O ... insere na lista visual uma linha para cada ingrediente da receita.
            ...drink.ingredients.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                // Texto secundário da linha; aqui mostra a medida ou avisa que ela não foi informada.
                subtitle: Text(item.measure ?? 'Medida não informada'),
                // Coloca um ícone no fim da linha para indicar que ela pode ser aberta.
                trailing: const Icon(Icons.chevron_right),
                // Ação executada ao tocar neste elemento, como abrir um cartão.
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
          // Lista os componentes filhos que serão desenhados dentro deste componente.
          children: [
            // Permite adaptar a disposição à largura disponível da tela.
            LayoutBuilder(
              // constraints informa o espaço disponível para decidir a disposição dos elementos.
              builder: (context, constraints) => constraints.maxWidth > 750
                  ? Row(
                      // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Lista os componentes filhos que serão desenhados dentro deste componente.
                      children: [
                        Expanded(
                          // Define o único componente filho que ocupa este espaço.
                          child: ApiPhoto(drink.summary.image, height: 440),
                        ),
                        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                        const SizedBox(width: 32),
                        Expanded(child: ingredients),
                      ],
                    )
                  : Column(
                      // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Lista os componentes filhos que serão desenhados dentro deste componente.
                      children: [
                        ApiPhoto(drink.summary.image, height: 300),
                        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                        const SizedBox(height: 24),
                        ingredients,
                      ],
                    ),
            ),
            // Construtor: recebe os dados deste componente. const permite instâncias constantes.
            const SizedBox(height: 32),
            heading('Modo de preparo'),
            // Construtor: recebe os dados deste componente. const permite instâncias constantes.
            const SizedBox(height: 12),
            Text(drink.instructions ?? 'Modo de preparo não informado.'),
            // Construtor: recebe os dados deste componente. const permite instâncias constantes.
            const SizedBox(height: 16),
            // Construtor: recebe os dados deste componente. const permite instâncias constantes.
            const Text(
              'Texto original da API. A TheCocktailDB não fornece o preparo em português.',
              style: TextStyle(color: Colors.grey),
            ),
            // Construtor: recebe os dados deste componente. const permite instâncias constantes.
            const SizedBox(height: 32),
            // Construtor: recebe os dados deste componente. const permite instâncias constantes.
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
