import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zest_drinks/pages/home_page.dart';
import 'package:zest_drinks/services/cocktail_api.dart';

void main() {
  for (final width in [390.0, 1200.0]) {
    testWidgets(
      'Busca, receita, ingrediente e resultado vazio em largura $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = CocktailApi(
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
        addTearDown(api.close);
        await tester.pumpWidget(MaterialApp(home: HomePage(api: api)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byType(TextField).first, 'Margarita');
        await tester.tap(find.text('Buscar'));
        await tester.pumpAndSettle();
        final card = find.text('Receita de teste');
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(find.text('Modo de preparo'), findsOneWidget);
        expect(find.text('30 ml'), findsOneWidget);
        await tester.ensureVisible(find.text('Gin'));
        await tester.tap(find.text('Gin'));
        await tester.pumpAndSettle();
        expect(find.text('Ver drinks com Gin'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(TextField).first);
        await tester.enterText(find.byType(TextField).first, 'inexistente');
        await tester.ensureVisible(find.text('Buscar'));
        await tester.tap(find.text('Buscar'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            'Nenhum drink encontrado. Tente outro nome, letra ou filtro.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
