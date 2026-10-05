// PONTO DE PARTIDA: inicia o aplicativo e define idioma, cores e primeira tela.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Importa os componentes visuais: telas, botões, campos, ícones e cores.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Disponibiliza esta página para abri-la a partir deste arquivo.
import 'pages/home_page.dart';
// Importa o serviço responsável por consultar a TheCocktailDB.
import 'services/cocktail_api.dart';
// Reutiliza os componentes e cores definidos em shared.dart.
import 'widgets/shared.dart';

// O Flutter começa por main(). runApp coloca o MeclazApp na tela.
void main() => runApp(const MeclazApp());

// Define um componente com estado: seus dados podem mudar durante o uso.
class MeclazApp extends StatefulWidget {
  // Construtor: recebe os dados deste componente. const permite instâncias constantes.
  const MeclazApp({super.key});
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Cria o objeto State que vai guardar os dados variáveis deste componente.
  State<MeclazApp> createState() => _MeclazAppState();
}

// Guarda os dados que mudam e as ações do componente associado a este State.
class _MeclazAppState extends State<MeclazApp> {
  // Uma instância compartilhada mantém o cache de listas entre as páginas.
  // Cria o objeto que fará as consultas. As telas compartilham este mesmo objeto.
  final api = CocktailApi();
  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Executa a limpeza de recursos quando este estado é removido definitivamente.
  void dispose() {
    // Fecha o cliente de rede quando o aplicativo deixa de usar este estado.
    api.close();
    // Conclui a limpeza interna exigida pelo Flutter.
    super.dispose();
  }

  // Indica que implementamos um método previsto pela classe de origem do Flutter/Dart.
  @override
  // Descreve a interface. context informa em que lugar da árvore de widgets estamos.
  Widget build(BuildContext context) => MaterialApp(
    // Nome do aplicativo usado pelo sistema; o nome do cabeçalho fica em home_page.dart.
    title: 'Meclaz • Drinks',
    // Esconde a faixa DEBUG no canto da tela durante o desenvolvimento.
    debugShowCheckedModeBanner: false,
    // Define português do Brasil para os componentes do Flutter.
    locale: const Locale('pt', 'BR'),
    // Lista os idiomas de interface que este aplicativo oferece.
    supportedLocales: const [Locale('pt', 'BR')],
    // Carrega as traduções dos componentes padrão, como mensagens de seleção de texto.
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      // Usa o conjunto de componentes visuais Material 3 do Flutter.
      useMaterial3: true,
      // Mantém branco o fundo das telas.
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: orange)
          .copyWith(primary: orange, surface: Colors.white, onSurface: ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: Colors.white,
          // Define o espaço interno entre o conteúdo e suas bordas.
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    ),
    // Abre HomePage primeiro e entrega a ela o serviço de consultas.
    home: HomePage(api: api),
  );
}
