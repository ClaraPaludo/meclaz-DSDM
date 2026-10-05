// DETALHE DO INGREDIENTE: mostra sua descrição e consulta os drinks relacionados.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Importa os componentes visuais: telas, botões, campos, ícones e cores.
import 'package:flutter/material.dart';

// Permite mostrar traduções dos rótulos conhecidos.
import '../labels_pt.dart';
// Importa os modelos que organizam os dados recebidos da API.
import '../models/drink.dart';
// Importa os modelos que organizam os dados recebidos da API.
import '../models/ingredient.dart';
// Importa o serviço responsável por consultar a TheCocktailDB.
import '../services/cocktail_api.dart';
// Reutiliza os componentes e cores definidos em shared.dart.
import '../widgets/shared.dart';
// Disponibiliza esta página para abri-la a partir deste arquivo.
import 'drink_detail_page.dart';

// Define um componente com estado: seus dados podem mudar durante o uso.
class IngredientDetailPage extends StatefulWidget {
  // Recebe o serviço da API de quem criou a tela; evita criar clientes novos a cada página.
  final CocktailApi api;
  // Guarda o nome. String é texto; final impede trocar este campo após a criação.
  final String name;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const IngredientDetailPage({
    // Repassa ao Flutter uma identificação opcional usada para reconhecer o componente.
    super.key,
    // Parâmetro obrigatório: guarda no campo de mesmo nome o valor recebido.
    required this.api,
    // Parâmetro obrigatório: guarda no campo de mesmo nome o valor recebido.
    required this.name,
  });
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Cria o objeto State que vai guardar os dados variáveis deste componente.
  State<IngredientDetailPage> createState() => _IngredientDetailPageState();
}

// Guarda os dados que mudam e as ações do componente associado a este State.
class _IngredientDetailPageState extends State<IngredientDetailPage> {
  // Consulta que trará os detalhes do ingrediente, ou null se ele não for encontrado.
  late Future<Ingredient?> ingredient;
  // Começa null: os drinks relacionados só são buscados quando o botão é tocado.
  Future<List<DrinkSummary>>? drinks;
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Executa a preparação uma única vez quando este estado é criado.
  void initState() {
    // Executa também a inicialização que o próprio Flutter precisa fazer.
    super.initState();
    // Busca na API os detalhes do nome recebido ao abrir esta página.
    ingredient = widget.api.ingredientByName(widget.name);
  }

  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ingrediente')),
    body: PageBody(
      // Lista os componentes filhos que serão desenhados dentro deste componente.
      children: [
        heading(widget.name, size: 38),
        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
        const SizedBox(height: 20),
        ApiPhoto(
          CocktailApi.ingredientImage(widget.name),
          height: 240,
          // Mostra a imagem inteira dentro da área reservada, sem cortar as bordas.
          fit: BoxFit.contain,
        ),
        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
        const SizedBox(height: 20),
        // Reconstrói esta parte da interface conforme a consulta carrega, termina ou falha.
        FutureBuilder<Ingredient?>(
          // Indica qual consulta assíncrona o FutureBuilder deve acompanhar.
          future: ingredient,
          // snapshot reúne o estado da consulta, os dados recebidos e um possível erro.
          builder: (context, snapshot) {
            // Enquanto a consulta não terminou, mostra o componente de espera logo abaixo.
            if (snapshot.connectionState != ConnectionState.done)
              return const Busy();
            // Se a consulta falhou, usa a mensagem de erro e a opção de nova tentativa.
            if (snapshot.hasError)
              return FeedbackBox(
                snapshot.error.toString(),
                // Função chamada pelo botão Tentar novamente quando houve uma falha.
                retry: () => setState(
                  () => ingredient = widget.api.ingredientByName(widget.name),
                ),
              );
            // Retira o ingrediente da resposta da consulta.
            final item = snapshot.data;
            if (item == null)
              return const FeedbackBox(
                'A API não tem uma descrição deste ingrediente. Você ainda pode consultar os drinks abaixo.',
              );
            return Column(
              // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
              crossAxisAlignment: CrossAxisAlignment.start,
              // Lista os componentes filhos que serão desenhados dentro deste componente.
              children: [
                Wrap(
                  // Define a distância entre elementos na mesma linha do Wrap.
                  spacing: 10,
                  // Define a distância entre as linhas quando o Wrap quebra o conteúdo.
                  runSpacing: 8,
                  // Lista os componentes filhos que serão desenhados dentro deste componente.
                  children: [
                    // Só mostra esta informação quando a API realmente forneceu seu valor.
                    if (item.type != null)
                      Chip(label: Text('Tipo: ${labelPt(item.type!)}')),
                    // Só mostra esta informação quando a API realmente forneceu seu valor.
                    if (item.alcohol != null)
                      Chip(
                        label: Text('Contém álcool: ${labelPt(item.alcohol!)}'),
                      ),
                    // Só mostra esta informação quando a API realmente forneceu seu valor.
                    if (item.abv != null)
                      Chip(label: Text('Teor alcoólico: ${item.abv}%')),
                  ],
                ),
                // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                const SizedBox(height: 16),
                Text(item.description ?? 'Descrição não informada pela API.'),
                // Só mostra esta informação quando a API realmente forneceu seu valor.
                if (item.description != null)
                  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                  const Padding(
                    // Define o espaço interno entre o conteúdo e suas bordas.
                    padding: EdgeInsets.only(top: 12),
                    // Define o único componente filho que ocupa este espaço.
                    child: Text(
                      'Descrição no idioma original da API.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            );
          },
        ),
        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
        const SizedBox(height: 28),
        FilledButton(
          // Ação executada ao clicar ou tocar no botão; a função não roda na montagem da tela.
          onPressed: () =>
              // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
              setState(() => drinks = widget.api.filter('i', widget.name)),
          // Define o único componente filho que ocupa este espaço.
          child: Text('Ver drinks com ${widget.name}'),
        ),
        // Só inclui este grupo de componentes depois que uma busca de drinks foi iniciada.
        if (drinks != null) ...[
          // Construtor: recebe os dados deste componente. const permite instâncias constantes.
          const SizedBox(height: 24),
          // Reconstrói esta parte da interface conforme a consulta carrega, termina ou falha.
          FutureBuilder<List<DrinkSummary>>(
            // Indica qual consulta assíncrona o FutureBuilder deve acompanhar.
            future: drinks,
            // snapshot reúne o estado da consulta, os dados recebidos e um possível erro.
            builder: (context, snapshot) {
              // Enquanto a consulta não terminou, mostra o componente de espera logo abaixo.
              if (snapshot.connectionState != ConnectionState.done)
                return const Busy();
              // Se a consulta falhou, usa a mensagem de erro e a opção de nova tentativa.
              if (snapshot.hasError)
                return FeedbackBox(
                  snapshot.error.toString(),
                  // Função chamada pelo botão Tentar novamente quando houve uma falha.
                  retry: () => setState(
                    () => drinks = widget.api.filter('i', widget.name),
                  ),
                );
              // Usa a lista recebida; se for null, usa [] para trabalhar com uma lista vazia.
              final items = snapshot.data ?? [];
              if (items.isEmpty)
                return const FeedbackBox(
                  'Nenhum drink encontrado com este ingrediente.',
                );
              return DrinkCards(
                drinks: items,
                onOpen: (id) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DrinkDetailPage(api: widget.api, id: id),
                  ),
                ),
              );
            },
          ),
        ],
        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
        const SizedBox(height: 32),
      ],
    ),
  );
}
