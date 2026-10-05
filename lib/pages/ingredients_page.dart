// CATÁLOGO DE INGREDIENTES: mostra a lista da API e permite pesquisar pelo nome.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Importa os componentes visuais: telas, botões, campos, ícones e cores.
import 'package:flutter/material.dart';

// Importa o serviço responsável por consultar a TheCocktailDB.
import '../services/cocktail_api.dart';
// Reutiliza os componentes e cores definidos em shared.dart.
import '../widgets/shared.dart';
// Disponibiliza esta página para abri-la a partir deste arquivo.
import 'ingredient_detail_page.dart';

// Define um componente com estado: seus dados podem mudar durante o uso.
class IngredientsPage extends StatefulWidget {
  // Recebe o serviço da API de quem criou a tela; evita criar clientes novos a cada página.
  final CocktailApi api;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const IngredientsPage({super.key, required this.api});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Cria o objeto State que vai guardar os dados variáveis deste componente.
  State<IngredientsPage> createState() => _IngredientsPageState();
}

// Guarda os dados que mudam e as ações do componente associado a este State.
class _IngredientsPageState extends State<IngredientsPage> {
  // Controla o campo de pesquisa: permite ler o texto digitado e limpar o campo.
  final search = TextEditingController();
  // Guarda a consulta que entregará os nomes de ingredientes para a lista.
  late Future<List<String>> results;
  // Guarda a pesquisa atual; a string vazia representa nenhum texto digitado.
  String term = '';
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Executa a preparação uma única vez quando este estado é criado.
  void initState() {
    // Executa também a inicialização que o próprio Flutter precisa fazer.
    super.initState();
    // Ao abrir, pede o catálogo de ingredientes; i é a chave de ingrediente na API.
    results = widget.api.listValues('i');
  }

  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Executa a limpeza de recursos quando este estado é removido definitivamente.
  void dispose() {
    // Libera o controlador do campo para ele não continuar ocupando recursos.
    search.dispose();
    // Conclui a limpeza interna exigida pelo Flutter.
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
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => PageBody(
    // Lista os componentes filhos que serão desenhados dentro deste componente.
    children: [
      heading('Tudo começa com\num ingrediente.', size: 38),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 16),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const Text('Conheça os ingredientes e encontre drinks que usam cada um.'),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 24),
      TextField(
        // Liga este campo ao controlador que lê e limpa o texto digitado.
        controller: search,
        // Executa a busca ao confirmar pelo teclado, sem precisar tocar no botão.
        onSubmitted: (_) => _load(),
        // Configura a ação de pesquisa exibida pelo teclado virtual.
        textInputAction: TextInputAction.search,
        // Configura a aparência, como fundo, borda ou identificação do campo.
        decoration: const InputDecoration(
          // Texto que identifica o campo para a pessoa que usa a tela.
          labelText: 'Nome do ingrediente na API, por exemplo: Gin',
          // Ícone desenhado antes do texto dentro do campo.
          prefixIcon: Icon(Icons.search),
        ),
      ),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 12),
      Wrap(
        // Define a distância entre elementos na mesma linha do Wrap.
        spacing: 12,
        // Lista os componentes filhos que serão desenhados dentro deste componente.
        children: [
          FilledButton(
            // Ação executada ao clicar ou tocar no botão; a função não roda na montagem da tela.
            onPressed: _load,
            // Define o único componente filho que ocupa este espaço.
            child: const Text('Buscar ingrediente'),
          ),
          TextButton(
            // Ação executada ao clicar ou tocar no botão; a função não roda na montagem da tela.
            onPressed: () {
              // Apaga o texto que aparecia no campo de pesquisa.
              search.clear();
              _load();
            },
            // Define o único componente filho que ocupa este espaço.
            child: const Text('Ver todos'),
          ),
        ],
      ),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 24),
      // Reconstrói esta parte da interface conforme a consulta carrega, termina ou falha.
      FutureBuilder<List<String>>(
        // Indica qual consulta assíncrona o FutureBuilder deve acompanhar.
        future: results,
        // snapshot reúne o estado da consulta, os dados recebidos e um possível erro.
        builder: (context, snapshot) {
          // Enquanto a consulta não terminou, mostra o componente de espera logo abaixo.
          if (snapshot.connectionState != ConnectionState.done)
            return const Busy();
          // Se a consulta falhou, usa a mensagem de erro e a opção de nova tentativa.
          if (snapshot.hasError)
            return FeedbackBox(snapshot.error.toString(), retry: _load);
          // Usa a lista recebida; se for null, usa [] para trabalhar com uma lista vazia.
          final items = snapshot.data ?? [];
          if (items.isEmpty)
            return const FeedbackBox(
              'Nenhum ingrediente encontrado. Tente o nome usado pela API, como Tequila.',
            );
          // A lista pode ser grande. Os blocos de texto são leves; fotos ficam
          // na página de detalhe para não baixar centenas de imagens de uma vez.
          return Column(
            // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
            crossAxisAlignment: CrossAxisAlignment.start,
            // Lista os componentes filhos que serão desenhados dentro deste componente.
            children: [
              Text('${items.length} ingredientes'),
              // Construtor: recebe os dados deste componente. const permite instâncias constantes.
              const SizedBox(height: 16),
              Wrap(
                // Define a distância entre elementos na mesma linha do Wrap.
                spacing: 10,
                // Define a distância entre as linhas quando o Wrap quebra o conteúdo.
                runSpacing: 10,
                // Lista os componentes filhos que serão desenhados dentro deste componente.
                children: items
                    // Transforma cada item da sequência; a função abaixo define o resultado de cada um.
                    .map(
                      (name) => ActionChip(
                        avatar: const Icon(Icons.eco_outlined, size: 18),
                        label: Text(name),
                        // Ação executada ao clicar ou tocar no botão; a função não roda na montagem da tela.
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
                    // Materializa os itens transformados em uma lista que pode ser usada pelo Flutter.
                    .toList(),
              ),
            ],
          );
        },
      ),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 32),
    ],
  );
}
