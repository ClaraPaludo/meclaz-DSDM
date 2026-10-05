# Zest — base de estudos em Flutter

Aplicativo de aprendizado baseado no wireframe aprovado: fundo branco, destaque laranja, títulos grandes e navegação simples. Receitas, nomes, imagens e ingredientes são consultados na TheCocktailDB. Nenhuma receita foi cadastrada manualmente.

**Comecem pela busca de um drink.** Depois acompanhem o código na ordem indicada abaixo. Não é necessário entender todos os arquivos de uma vez.

## 1. O que estamos usando

- **Dart:** linguagem em que o código foi escrito.
- **Flutter:** ferramenta que desenha as telas e executa o aplicativo.
- **TheCocktailDB:** API que fornece os dados pela internet.
- **http:** pacote Dart usado para enviar requisições GET.

A escolha de Flutter/Dart segue o PDF “Documentação TheCocktailDB API para app Flutter”. A API pode ser usada com outras linguagens, mas ela própria não é uma linguagem de programação.

## 2. Como abrir e executar

### Primeira instalação

1. Instale o Flutter estável (versão 3.35 ou superior) e a extensão Flutter no VS Code seguindo o [guia oficial](https://docs.flutter.dev/install/quick). A extensão também instala o suporte a Dart.
2. Feche e abra novamente o VS Code após adicionar o Flutter ao PATH.
3. Tenha o Google Chrome instalado para começar pela versão web. Não é necessário configurar um emulador Android para esta primeira etapa.
4. Extraia o ZIP. No VS Code, use **Arquivo → Abrir Pasta** e escolha a pasta `zest-flutter-base`, aquela que contém `pubspec.yaml`.
5. Abra **Terminal → Novo Terminal** nessa pasta.

Execute os comandos um de cada vez:

```bash
flutter doctor
flutter pub get
flutter run -d chrome
```

`flutter doctor` verifica a instalação. Avisos sobre Android Studio não impedem executar a versão web. `flutter pub get` baixa as dependências. `flutter run -d chrome` compila o projeto e abre o aplicativo.

Não abra `web/index.html` com duplo clique e não use Live Server: este é um projeto Flutter, que precisa ser compilado pelo comando acima.

Ao editar um arquivo, salve e use o botão de recarregar do Flutter no VS Code; pelo terminal de execução, pressione `r`. Para encerrar, pressione `q`.

### Testes e análise

```bash
flutter analyze
flutter test
flutter build web
```

Os testes usam respostas simuladas, sem depender da disponibilidade da API. A compilação web é uma verificação adicional, não é necessária a cada alteração.

### Android, em uma segunda etapa

A entrega está preparada para começar no navegador. Para adicionar a estrutura Android, execute na pasta do projeto:

```bash
flutter create --platforms=android --project-name zest_drinks .
```

Depois, em `android/app/src/main/AndroidManifest.xml`, adicione esta linha diretamente dentro de `<manifest>`, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Instale/configure o Android SDK e um emulador ou conecte um aparelho com depuração USB, seguindo o guia oficial do Flutter. Depois execute:

```bash
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

Troque `ID_DO_DISPOSITIVO` pelo identificador exibido em `flutter devices`. O projeto não precisa de banco de dados, login ou servidor próprio.

## 3. O que já funciona

| Área | Comportamento |
| --- | --- |
| Início / Drinks | Carrega os drinks da letra A; a foto de destaque vem da primeira resposta da API. |
| Busca | Consulta drinks pelo nome ao clicar em Buscar ou pressionar Enter. |
| A–Z | Consulta os drinks pela primeira letra. |
| Filtros | Categoria, presença de álcool, copo ou ingrediente. Um filtro por vez. |
| Receita | Busca os detalhes por ID ao abrir um cartão. Mostra foto, categoria, copo, ingredientes, medidas e preparo. |
| Ingredientes | Carrega o catálogo da API e permite buscar ingrediente pelo nome. |
| Detalhe do ingrediente | Mostra foto, descrição, tipo, álcool e teor alcoólico quando informados. |
| Drinks por ingrediente | O botão “Ver drinks com…” carrega receitas que usam o ingrediente. |
| Estados | Carregamento, ausência de resultados, erro, tentar novamente e imagem indisponível. |

A área **Descobrir**, o sorteio **Surpreenda-me** e as funções Premium ficaram para uma próxima etapa. Esta é a base funcional, com o visual simplificado para facilitar o estudo. Na lista de ingredientes, usamos botões com nomes; as fotos aparecem nos detalhes, evitando baixar centenas de imagens de uma só vez.

## 4. Entendendo os arquivos

| Arquivo | Responsabilidade |
| --- | --- |
| `lib/main.dart` | Inicia o aplicativo, define idioma/tema e cria o serviço da API. |
| `lib/pages/home_page.dart` | Alterna entre Drinks e Ingredientes e preserva a busca entre abas. |
| `lib/pages/drinks_page.dart` | Campo de busca, filtros, letras, resultados e controle de carregamento. |
| `lib/pages/drink_detail_page.dart` | Exibe a receita completa e abre ingredientes ao tocar neles. |
| `lib/pages/ingredients_page.dart` | Lista e busca ingredientes. |
| `lib/pages/ingredient_detail_page.dart` | Exibe informações do ingrediente e drinks relacionados. |
| `lib/services/cocktail_api.dart` | Monta URLs, faz GET, lê JSON, trata falhas e mantém as listas em memória. |
| `lib/models/drink.dart` | Representa resumo, receita completa e pares de ingrediente/medida. |
| `lib/models/ingredient.dart` | Representa os detalhes de um ingrediente. |
| `lib/widgets/shared.dart` | Componentes reutilizados: cartões, imagens, títulos e mensagens. Também contém as cores. |
| `lib/labels_pt.dart` | Traduz rótulos conhecidos sem alterar os valores enviados à API. |
| `test/` | Testes automatizados de dados, serviço e interface. |
| `pubspec.yaml` | Nome do projeto, requisitos e dependências. |

A pasta `web` contém a estrutura necessária para executar no navegador; a pasta `android` pode ser gerada na etapa opcional acima. Para estudar as funcionalidades, comecem pela pasta `lib`.

### Ordem de leitura sugerida

1. `main.dart`: encontre `runApp`, `MaterialApp` e `home`.
2. `drinks_page.dart`: encontre `_search()` e veja o que o botão chama.
3. `cocktail_api.dart`: encontre `searchByName()` e `_get()`.
4. `drink.dart`: acompanhe `DrinkSummary.fromJson()`.
5. Volte para `drinks_page.dart`: veja `_load()` e `DrinkCards`.
6. Abra `drink_detail_page.dart` para entender a consulta por ID.

## 5. Caminho de uma busca, passo a passo

Exemplo: pesquisar **Margarita**.

1. O texto digitado fica no `TextEditingController` chamado `search`.
2. O botão chama `_search()`, que remove espaços e verifica se o texto está vazio.
3. `_load()` liga `loading`, limpa o erro anterior e pede os dados ao serviço.
4. `searchByName('Margarita')` chama `_get('search.php', {'s': 'Margarita'})`.
5. `Uri.https` constrói a URL e codifica caracteres especiais. `http.Client.get` envia o GET.
6. A API responde com JSON. `jsonDecode` transforma o texto em mapas e listas Dart.
7. `DrinkSummary.fromJson` transforma cada mapa em um objeto com `id`, `name` e `image`.
8. `setState()` salva a lista e pede que o Flutter redesenhe a tela.
9. Ao tocar em um cartão, `Navigator.push` abre a receita e consulta `lookup.php?i=ID`.

### Termos que aparecem no código

- **Widget:** uma parte da interface, como texto, botão, tela ou cartão.
- **StatefulWidget:** widget que guarda informações que podem mudar, como resultados de uma busca.
- **setState:** informa ao Flutter que o estado mudou e a interface precisa ser reconstruída.
- **Future:** resultado que chegará depois, como uma resposta de rede.
- **async / await:** permitem esperar esse resultado sem bloquear a interface.
- **FutureBuilder:** constrói uma parte da tela conforme a consulta carrega, termina ou falha.
- **initState:** executa a inicialização uma vez; evita repetir requisições a cada reconstrução da tela.
- **dispose:** libera recursos, como o controlador do campo e o cliente HTTP.
- **mounted:** verifica se a tela ainda está aberta antes de atualizá-la.
- **fromJson:** método que transforma dados recebidos em um objeto da aplicação.

## 6. Endpoints usados

Base: `https://www.thecocktaildb.com/api/json/v1/1/`

| Método do serviço | Endpoint | Uso |
| --- | --- | --- |
| `searchByName(nome)` | `search.php?s=nome` | Busca por nome. |
| `searchByLetter(letra)` | `search.php?f=letra` | A–Z. |
| `drinkById(id)` | `lookup.php?i=id` | Receita completa. |
| `filter('c', valor)` | `filter.php?c=valor` | Categoria. |
| `filter('a', valor)` | `filter.php?a=valor` | Presença de álcool. |
| `filter('g', valor)` | `filter.php?g=valor` | Copo. |
| `filter('i', valor)` | `filter.php?i=valor` | Ingrediente. |
| `listValues(tipo)` | `list.php?c=list`, `g=list`, `i=list` ou `a=list` | Opções da API. |
| `searchIngredients(nome)` | `search.php?i=nome` | Pesquisa de ingredientes. |
| `ingredientByName(nome)` | `search.php?i=nome` | Usa a pesquisa para abrir um ingrediente. |
| `ingredientById(id)` | `lookup.php?iid=id` | Disponível no serviço para estudar a consulta por ID. |

A interface navega pelos ingredientes usando seus nomes porque o catálogo `list.php?i=list` não entrega IDs. O método por ID está implementado e testado, mas não precisa de um campo de ID na tela.

## 7. Cuidados importantes com os dados

- A chave `1` é a chave de testes/estudo indicada no PDF. Não é uma chave de produção própria.
- A API é somente leitura. Não há cadastro, edição ou exclusão de receitas nesta base.
- O resultado de `filter.php` tem apenas nome, ID e imagem. A receita completa exige `lookup.php`.
- Um filtro substitui a busca anterior. Não estamos simulando uma combinação de filtros que a API gratuita não oferece.
- A interface e os rótulos conhecidos estão em português. Nomes de ingredientes, receitas e textos descritivos permanecem como a API os retorna. Ela não oferece um campo de preparo em português.
- Pesquise pelo nome conhecido pela API, como **Gin**, **Margarita** ou **Lime**. O aplicativo não traduz automaticamente o que foi digitado.
- IDs continuam sendo `String`. Campos vazios ou `null` são tratados sem inventar informações.
- Ingredientes e medidas usam os mesmos índices, de 1 a 15. Medida ausente aparece como “Medida não informada”.
- `drinks: null` e `drinks: "None Found"` viram listas vazias.
- As opções dos filtros ficam em cache durante a execução. As receitas continuam sendo consultadas na API.
- A chamada tem limite de 20 segundos. Sem internet ou em caso de falha, a tela apresenta uma mensagem e permite tentar novamente.
- Se duas buscas forem feitas rapidamente, um contador impede que a resposta antiga substitua a mais recente.
- As listas da API não têm paginação implementada nesta base. Grandes listas podem ser extensas; isso pode ser refinado depois.

## 8. Exercícios pequenos para aprender

1. Pesquisem Margarita e encontrem o método que faz o GET.
2. Pesquisem um nome inexistente e localizem a mensagem de lista vazia.
3. Abram uma receita e acompanhem de onde veio o ID.
4. Toquem em um ingrediente e depois em “Ver drinks com…”.
5. Mudem a cor `orange` em `shared.dart` e recarreguem o aplicativo.
6. Adicionem uma tradução de rótulo em `labels_pt.dart`. Mantenham a chave original à esquerda.

Evitem adicionar várias funções ao mesmo tempo: façam uma alteração, executem e observem o resultado.

## 9. Fontes

- PDF fornecido: “Documentação API Drinks.pdf”.
- [TheCocktailDB — API](https://www.thecocktaildb.com/api.php)
- [Flutter — instalação](https://docs.flutter.dev/install/quick)
- [Flutter — consultas HTTP](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [Pacote http](https://pub.dev/packages/http)

O arquivo `VALIDACAO.md` registra o que foi efetivamente verificado nesta entrega.
