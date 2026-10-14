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
import 'ingredient_mix_page.dart';

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
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: PageBody(
      children: [
        heading('Tudo começa com\num ingrediente.', size: 38),
        const SizedBox(height: 16),
        const Text(
          'Conheça os ingredientes e encontre drinks que usam cada um.',
        ),
        const SizedBox(height: 24),

        const TabBar(
          tabs: [
            Tab(text: 'Ingredientes'),
            Tab(text: 'Combinar ingredientes'),
          ],
        ),
        SizedBox(
          height: 650,
          child: TabBarView(
            children: [
              _catalogTab(),
              IngredientMixPage(api: widget.api),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _catalogTab() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
          if (snapshot.connectionState != ConnectionState.done) {
            return const Busy();
          }
          if (snapshot.hasError) {
            return FeedbackBox(snapshot.error.toString(), retry: _load);
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const FeedbackBox(
              'Nenhum ingrediente encontrado. Tente o nome usado pela API, como Tequila.',
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${items.length} ingredientes'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: items.map((name) {
                  return ActionChip(
                    avatar: const Icon(Icons.eco_outlined, size: 18),
                    label: Text(name),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            IngredientDetailPage(api: widget.api, name: name),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    ],
  );
}
