// NAVEGAÇÃO PRINCIPAL: escolhe qual das duas abas aparece para o usuário.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Importa os componentes visuais: telas, botões, campos, ícones e cores.
import 'package:flutter/material.dart';

// Importa o serviço responsável por consultar a TheCocktailDB.
import '../services/cocktail_api.dart';
// Reutiliza os componentes e cores definidos em shared.dart.
import '../widgets/shared.dart';
// Disponibiliza esta página para abri-la a partir deste arquivo.
import 'drinks_page.dart';
// Disponibiliza esta página para abri-la a partir deste arquivo.
import 'ingredients_page.dart';

// Define um componente com estado: seus dados podem mudar durante o uso.
class HomePage extends StatefulWidget {
  // Recebe o serviço da API de quem criou a tela; evita criar clientes novos a cada página.
  final CocktailApi api;
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const HomePage({super.key, required this.api});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Cria o objeto State que vai guardar os dados variáveis deste componente.
  State<HomePage> createState() => _HomePageState();
}

// Guarda os dados que mudam e as ações do componente associado a este State.
class _HomePageState extends State<HomePage> {
  // Índice da aba visível: 0 = Drinks; 1 = Ingredientes.
  int tab = 0;
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'meclaz.',
        style: const TextStyle(
          // Escolhe a família da fonte para o texto.
          fontFamily: 'Georgia',
          // Define o tamanho da fonte em unidades lógicas do Flutter.
          fontSize: 32,
          color: orange,
        ),
      ),
      actions: [
        TextButton(
          // Ação executada ao clicar ou tocar no botão; a função não roda na montagem da tela.
          onPressed: () => setState(() => tab = 0),
          // Define o único componente filho que ocupa este espaço.
          child: Text(
            'Drinks',
            style: TextStyle(
              // Escolhe o peso da fonte; neste menu, destaca a aba selecionada.
              fontWeight: tab == 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          // Ação executada ao clicar ou tocar no botão; a função não roda na montagem da tela.
          onPressed: () => setState(() => tab = 1),
          // Define o único componente filho que ocupa este espaço.
          child: Text(
            'Ingredientes',
            style: TextStyle(
              // Escolhe o peso da fonte; neste menu, destaca a aba selecionada.
              fontWeight: tab == 1 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        // Construtor: recebe os dados deste componente. const permite instâncias constantes.
        const SizedBox(width: 12),
      ],
    ),
    // IndexedStack preserva a pesquisa quando o usuário muda de aba.
    body: IndexedStack(
      // Mostra o filho na posição indicada por tab; os outros preservam seu estado.
      index: tab,
      // Lista os componentes filhos que serão desenhados dentro deste componente.
      children: [
        DrinksPage(api: widget.api),
        IngredientsPage(api: widget.api),
      ],
    ),
  );
}
