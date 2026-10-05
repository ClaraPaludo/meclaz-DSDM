// TESTES: verificam o comportamento usando dados simulados; não alteram as telas do aplicativo.
// Os comentários são explicações para estudo: não são executados pelo Dart.
// Leia primeiro o objetivo da função e depois acompanhe as instruções abaixo dela.

// Disponibiliza jsonDecode/jsonEncode para converter entre texto JSON e objetos.
import 'dart:convert';

// Importa os componentes visuais: telas, botões, campos, ícones e cores.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Importa o pacote de rede com o apelido http para identificar seus tipos.
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
// Disponibiliza esta página para abri-la a partir deste arquivo.
import 'package:meclaz_drinks/pages/home_page.dart';
// Importa o serviço responsável por consultar a TheCocktailDB.
import 'package:meclaz_drinks/services/cocktail_api.dart';

void main() {
  for (final width in [390.0, 1200.0]) {
    // Executa um cenário de interface simulando uma pessoa usando a tela.
    testWidgets(
      'Busca, receita, ingrediente e resultado vazio em largura $width',
      (tester) async {
        // Define o tamanho da tela simulada neste teste.
        tester.view.physicalSize = Size(width, 900);
        // Usa escala 1 para que as medidas do teste sejam diretas.
        tester.view.devicePixelRatio = 1;
        // Agenda uma limpeza que será executada depois do teste, mesmo se ele falhar.
        addTearDown(tester.view.resetPhysicalSize);
        // Agenda uma limpeza que será executada depois do teste, mesmo se ele falhar.
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = CocktailApi(
          // Substitui a internet por respostas controladas, para tornar o teste previsível.
          client: MockClient((request) async {
            final q = request.url.queryParameters;
            Object? data;
            String root = 'drinks';
            if (request.url.path.endsWith('list.php')) {
              data = q.containsKey('i')
                  ? [
                      {'strIngredient1': 'Gin'},
                    ]
                  : [
                      {'strCategory': 'Cocktail'},
                    ];
            } else if (request.url.path.endsWith('lookup.php')) {
              data = [
                {
                  'idDrink': '42',
                  'strDrink': 'Receita de teste',
                  'strIngredient1': 'Gin',
                  'strMeasure1': '30 ml',
                  'strInstructions': 'Mix.',
                },
              ];
            } else if (q.containsKey('i')) {
              root = 'ingredients';
              data = [
                {
                  'idIngredient': '1',
                  'strIngredient': 'Gin',
                  'strDescription': 'Test description.',
                },
              ];
            } else if (q['s'] == 'Margarita') {
              data = [
                {'idDrink': '42', 'strDrink': 'Receita de teste'},
              ];
            } else {
              data = null;
            }
            return http.Response(jsonEncode({root: data}), 200);
          }),
        );
        // Agenda uma limpeza que será executada depois do teste, mesmo se ele falhar.
        addTearDown(api.close);
        // Monta o aplicativo de teste para que seja possível interagir com seus componentes.
        await tester.pumpWidget(MaterialApp(home: HomePage(api: api)));
        // Processa os quadros da interface até não haver mais quadros agendados.
        await tester.pumpAndSettle();
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(tester.takeException(), isNull);
        // Simula a digitação no campo localizado pelo teste.
        await tester.enterText(find.byType(TextField).first, 'Margarita');
        // Simula um toque no botão ou texto encontrado.
        await tester.tap(find.text('Buscar'));
        // Processa os quadros da interface até não haver mais quadros agendados.
        await tester.pumpAndSettle();
        final card = find.text('Receita de teste');
        // Rola a tela para que o elemento possa ser visto antes da interação.
        await tester.ensureVisible(card);
        // Simula um toque no botão ou texto encontrado.
        await tester.tap(card);
        // Processa os quadros da interface até não haver mais quadros agendados.
        await tester.pumpAndSettle();
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(find.text('Modo de preparo'), findsOneWidget);
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(find.text('30 ml'), findsOneWidget);
        // Rola a tela para que o elemento possa ser visto antes da interação.
        await tester.ensureVisible(find.text('Gin'));
        // Simula um toque no botão ou texto encontrado.
        await tester.tap(find.text('Gin'));
        // Processa os quadros da interface até não haver mais quadros agendados.
        await tester.pumpAndSettle();
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(find.text('Ver drinks com Gin'), findsOneWidget);
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(tester.takeException(), isNull);
        // Simula a ação de voltar para a página anterior.
        await tester.pageBack();
        // Processa os quadros da interface até não haver mais quadros agendados.
        await tester.pumpAndSettle();
        // Simula a ação de voltar para a página anterior.
        await tester.pageBack();
        // Processa os quadros da interface até não haver mais quadros agendados.
        await tester.pumpAndSettle();
        // Rola a tela para que o elemento possa ser visto antes da interação.
        await tester.ensureVisible(find.byType(TextField).first);
        // Simula a digitação no campo localizado pelo teste.
        await tester.enterText(find.byType(TextField).first, 'inexistente');
        // Rola a tela para que o elemento possa ser visto antes da interação.
        await tester.ensureVisible(find.text('Buscar'));
        // Simula um toque no botão ou texto encontrado.
        await tester.tap(find.text('Buscar'));
        // Processa os quadros da interface até não haver mais quadros agendados.
        await tester.pumpAndSettle();
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(
          find.text(
            'Nenhum drink encontrado. Tente outro nome, letra ou filtro.',
          ),
          findsOneWidget,
        );
        // Compara o valor observado com o esperado. Uma diferença faz o teste falhar.
        expect(tester.takeException(), isNull);
      },
    );
  }
}
