// TELA DE DRINKS: recebe a busca, consulta a API e mostra os resultados.
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
import 'drink_detail_page.dart';

// Define um componente com estado: seus dados podem mudar durante o uso.
class DrinksPage extends StatefulWidget {
  // Recebe o serviço da API de quem criou a tela; evita criar clientes novos a cada página.
  final CocktailApi api;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const DrinksPage({super.key, required this.api});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Cria o objeto State que vai guardar os dados variáveis deste componente.
  State<DrinksPage> createState() => _DrinksPageState();
}

// Guarda os dados que mudam e as ações do componente associado a este State.
class _DrinksPageState extends State<DrinksPage> {
  // Controla o campo de pesquisa: permite ler o texto digitado e limpar o campo.
  final search = TextEditingController();
  // Guarda os cartões encontrados. [] significa que a lista começa vazia.
  List<DrinkSummary> drinks = [];
  // Indica se uma consulta está carregando; true faz aparecer a espera.
  bool loading = true;
  // Guarda uma mensagem de erro. O ? permite null, que aqui significa sem erro.
  String? error;
  // Texto acima dos resultados; muda conforme a busca ou o filtro escolhido.
  String title = 'Para começar • letra A';
  // Tipo de filtro: c = categoria, a = álcool, g = copo, i = ingrediente.
  String kind = 'c';
  // Opção escolhida no filtro. null indica que nenhuma opção está selecionada.
  String? value;
  // Consulta que vai trazer as opções do filtro. late indica atribuição antes do uso.
  late Future<List<String>> options;
  // Guarda a função da última busca para o botão Tentar novamente repeti-la.
  late Future<List<DrinkSummary>> Function() lastQuery;
  // Contador usado para distinguir uma busca antiga da busca mais recente.
  int request = 0;

  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Executa a preparação uma única vez quando este estado é criado.
  void initState() {
    // Executa também a inicialização que o próprio Flutter precisa fazer.
    super.initState();
    // Pede à API as opções do tipo de filtro atual.
    options = widget.api.listValues(kind);
    // Na abertura, carrega drinks com A. () => passa uma função para _load executar.
    _load(() => widget.api.searchByLetter('a'));
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

  Future<void> _load(Future<List<DrinkSummary>> Function() query) async {
    // Memoriza qual consulta deve ser refeita se o usuário pedir outra tentativa.
    lastQuery = query;
    // Soma 1 ao contador e guarda o número desta consulta.
    final ticket = ++request;
    // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
    setState(() {
      // Liga o indicador de espera enquanto os dados ainda não chegaram.
      loading = true;
      // Remove a mensagem de erro da consulta anterior.
      error = null;
    });
    try {
      // Executa a consulta recebida e espera a resposta, sem travar a interface.
      final result = await query();
      // Se outra pesquisa terminou antes, esta resposta antiga é ignorada.
      // Sai sem atualizar se a tela foi fechada ou se uma busca mais nova já começou.
      if (!mounted || ticket != request) return;
      // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
      setState(() {
        // Substitui a lista anterior pelos drinks que acabaram de chegar.
        drinks = result;
        // Desliga o indicador de espera porque a consulta terminou.
        loading = false;
      });
    // Captura uma falha para convertê-la em uma mensagem em vez de deixar a tela sem tratamento.
    } catch (e) {
      // Sai sem atualizar se a tela foi fechada ou se uma busca mais nova já começou.
      if (!mounted || ticket != request) return;
      // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
      setState(() {
        // Transforma a falha capturada em texto para mostrar ao usuário.
        error = e.toString();
        // Desliga o indicador de espera porque a consulta terminou.
        loading = false;
      });
    }
  }

  // Esta função é executada pelo botão Buscar e pela tecla de envio do campo.
  void _search() {
    // Lê a pesquisa e remove espaços do começo e do fim.
    final term = search.text.trim();
    // Verifica se a pessoa tentou buscar sem digitar um nome.
    if (term.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
        const SnackBar(content: Text('Digite o nome de um drink.')),
      );
      // Encerra esta função aqui; as instruções seguintes não serão executadas.
      return;
    }
    // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
    setState(() {
      // Limpa a opção de filtro que estava selecionada.
      value = null;
      title = 'Resultados para “$term”';
    });
    // Envia o nome digitado para a busca e atualiza os estados de espera/resultado.
    _load(() => widget.api.searchByName(term));
  }

  // Abre a página de receita e leva junto o ID do drink escolhido.
  void _open(String id) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DrinkDetailPage(api: widget.api, id: id),
    ),
  );

  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => PageBody(
    // Lista os componentes filhos que serão desenhados dentro deste componente.
    children: [
      Container(
        // Define o espaço interno entre o conteúdo e suas bordas.
        padding: const EdgeInsets.all(24),
        // Configura a aparência, como fundo, borda ou identificação do campo.
        decoration: BoxDecoration(
          color: peach,
          // Arredonda os cantos sem mudar a função do componente.
          borderRadius: BorderRadius.circular(26),
        ),
        // Define o único componente filho que ocupa este espaço.
        child: LayoutBuilder(
          // constraints informa o espaço disponível para decidir a disposição dos elementos.
          builder: (context, constraints) {
            final intro = Column(
              // Alinha os filhos no início do eixo transversal: à esquerda na Column, no topo na Row.
              crossAxisAlignment: CrossAxisAlignment.start,
              // Lista os componentes filhos que serão desenhados dentro deste componente.
              children: [
                heading(
                  'Qual vai ser o\ndrink de hoje?',
                  size: constraints.maxWidth < 500 ? 34 : 44,
                ),
                // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                const SizedBox(height: 16),
                // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                const Text(
                  'Uma receita conhecida ou uma nova combinação.\nEncontre a sua próxima escolha.',
                ),
                // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                const SizedBox(height: 24),
                TextField(
                  // Liga este campo ao controlador que lê e limpa o texto digitado.
                  controller: search,
                  // Configura a ação de pesquisa exibida pelo teclado virtual.
                  textInputAction: TextInputAction.search,
                  // Executa a busca ao confirmar pelo teclado, sem precisar tocar no botão.
                  onSubmitted: (_) => _search(),
                  // Configura a aparência, como fundo, borda ou identificação do campo.
                  decoration: const InputDecoration(
                    // Texto que identifica o campo para a pessoa que usa a tela.
                    labelText: 'Busque um drink pelo nome',
                    // Ícone desenhado antes do texto dentro do campo.
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                const SizedBox(height: 12),
                FilledButton(onPressed: _search, child: const Text('Buscar')),
              ],
            );
            // A foto vem do resultado da API, sem receita ou imagem fixa no código.
            return constraints.maxWidth > 750 && drinks.isNotEmpty
                ? Row(
                    // Lista os componentes filhos que serão desenhados dentro deste componente.
                    children: [
                      Expanded(child: intro),
                      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
                      const SizedBox(width: 30),
                      SizedBox(
                        width: 300,
                        // Define o único componente filho que ocupa este espaço.
                        child: ApiPhoto(drinks.first.image, height: 280),
                      ),
                    ],
                  )
                : intro;
          },
        ),
      ),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 28),
      heading('Encontre pelo seu estilo'),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 12),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const Text(
        'Escolha um filtro por vez. Uma nova busca substitui o filtro anterior.',
      ),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        // Define a seleção inicial deste campo.
        initialValue: kind,
        // Configura a aparência, como fundo, borda ou identificação do campo.
        decoration: const InputDecoration(labelText: 'Filtrar por'),
        items: const [
          DropdownMenuItem(value: 'c', child: Text('Categoria')),
          DropdownMenuItem(value: 'a', child: Text('Presença de álcool')),
          DropdownMenuItem(value: 'g', child: Text('Tipo de copo')),
          DropdownMenuItem(value: 'i', child: Text('Ingrediente')),
        ],
        // Recebe a nova opção quando a pessoa muda a seleção deste menu.
        onChanged: (next) {
          if (next != null)
            // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
            setState(() {
              // Salva o novo tipo de filtro escolhido no menu.
              kind = next;
              // Limpa a opção de filtro que estava selecionada.
              value = null;
              // Pede à API as opções do tipo de filtro atual.
              options = widget.api.listValues(kind);
            });
        },
      ),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 12),
      // Reconstrói esta parte da interface conforme a consulta carrega, termina ou falha.
      FutureBuilder<List<String>>(
        // Indica qual consulta assíncrona o FutureBuilder deve acompanhar.
        future: options,
        // snapshot reúne o estado da consulta, os dados recebidos e um possível erro.
        builder: (context, snapshot) {
          // Enquanto a consulta não terminou, mostra o componente de espera logo abaixo.
          if (snapshot.connectionState != ConnectionState.done)
            return const LinearProgressIndicator();
          // Se a consulta falhou, usa a mensagem de erro e a opção de nova tentativa.
          if (snapshot.hasError)
            return FeedbackBox(
              'Não foi possível carregar os filtros.',
              // Função chamada pelo botão Tentar novamente quando houve uma falha.
              retry: () =>
                  // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
                  setState(() => options = widget.api.listValues(kind)),
            );
          // Lê as opções recebidas; ?? [] evita usar uma lista nula.
          final values = snapshot.data ?? [];
          if (values.isEmpty)
            return const FeedbackBox('A API não retornou opções de filtro.');
          return DropdownButtonFormField<String>(
            // Identifica o campo pelos valores atuais para reiniciá-lo quando a seleção mudar.
            key: ValueKey('$kind:$value'),
            // Define a seleção inicial deste campo.
            initialValue: value,
            // Permite que o conteúdo do menu aproveite a largura disponível.
            isExpanded: true,
            // Configura a aparência, como fundo, borda ou identificação do campo.
            decoration: const InputDecoration(labelText: 'Selecione uma opção'),
            items: values
                // Transforma cada item da sequência; a função abaixo define o resultado de cada um.
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    // Define o único componente filho que ocupa este espaço.
                    child: Text(labelPt(item), overflow: TextOverflow.ellipsis),
                  ),
                )
                // Materializa os itens transformados em uma lista que pode ser usada pelo Flutter.
                .toList(),
            // Recebe a nova opção quando a pessoa muda a seleção deste menu.
            onChanged: (next) {
              if (next == null) return;
              // Guarda o tipo de filtro desta busca para usá-lo na chamada à API.
              final selectedKind = kind;
              // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
              setState(() {
                // Salva a opção escolhida, como uma categoria ou um ingrediente.
                value = next;
                // Apaga o texto que aparecia no campo de pesquisa.
                search.clear();
                title = labelPt(next);
              });
              // Consulta apenas o filtro escolhido, usando os valores originais da API.
              _load(() => widget.api.filter(selectedKind, next));
            },
          );
        },
      ),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 24),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const Text('Ou explore pela primeira letra'),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 8),
      Wrap(
        // Define a distância entre elementos na mesma linha do Wrap.
        spacing: 4,
        // Define a distância entre as linhas quando o Wrap quebra o conteúdo.
        runSpacing: 4,
        // Lista os componentes filhos que serão desenhados dentro deste componente.
        children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            // Divide o texto em letras para gerar um botão para cada letra do alfabeto.
            .split('')
            // Transforma cada item da sequência; a função abaixo define o resultado de cada um.
            .map(
              (letter) => TextButton(
                // Ação executada ao clicar ou tocar no botão; a função não roda na montagem da tela.
                onPressed: () {
                  // Salva mudanças no estado e solicita ao Flutter que atualize a interface.
                  setState(() {
                    // Limpa a opção de filtro que estava selecionada.
                    value = null;
                    // Apaga o texto que aparecia no campo de pesquisa.
                    search.clear();
                    title = 'Drinks com a letra $letter';
                  });
                  _load(() => widget.api.searchByLetter(letter.toLowerCase()));
                },
                // Define o único componente filho que ocupa este espaço.
                child: Text(letter),
              ),
            )
            // Materializa os itens transformados em uma lista que pode ser usada pelo Flutter.
            .toList(),
      ),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 24),
      heading(title),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 18),
      if (loading)
        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
        const Busy()
      else if (error != null)
        FeedbackBox(error!, retry: () => _load(lastQuery))
      else if (drinks.isEmpty)
        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
        const FeedbackBox(
          'Nenhum drink encontrado. Tente outro nome, letra ou filtro.',
        )
      else
        DrinkCards(drinks: drinks, onOpen: _open),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 40),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const Divider(),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const Text('Receitas e fotos: TheCocktailDB'),
      // Construtor: recebe os dados deste componente. const permite instâncias constantes.
      const SizedBox(height: 12),
    ],
  );
}
