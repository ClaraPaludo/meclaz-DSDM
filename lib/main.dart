import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/home_page.dart';
import 'services/cocktail_api.dart';
import 'widgets/shared.dart';

void main() => runApp(const ZestApp());

class ZestApp extends StatefulWidget {
  const ZestApp({super.key});
  @override
  State<ZestApp> createState() => _ZestAppState();
}

class _ZestAppState extends State<ZestApp> {
  // Uma instância compartilhada mantém o cache de listas entre as páginas.
  final api = CocktailApi();
  @override
  void dispose() {
    api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Zest • Drinks',
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    ),
    home: HomePage(api: api),
  );
}
