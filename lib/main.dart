import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

var rainbowColors = [Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 17, 92, 255)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var deletedFavs = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite(wordPair) {
    if (favorites.contains(wordPair)) {
      favorites.remove(wordPair);
    } else {
      favorites.add(wordPair);
      deletedFavs.remove(wordPair);
    }
    notifyListeners();
  }

  void deleteFavorite(wordPair) {
      favorites.remove(wordPair);
      deletedFavs.add(wordPair);
    notifyListeners();
  }

  void reFavorite(wordPair) {
    if (!favorites.contains(wordPair)){
      favorites.add(wordPair);
    }
  }

  void deleteForever(wordPair) {
      deletedFavs.remove(wordPair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    Widget page;
    Color background = Theme.of(context).colorScheme.primaryContainer;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        background = Theme.of(context).colorScheme.primaryContainer;
        break;
      case 1:
        page = FavoritesPage();
        background = Theme.of(context).colorScheme.tertiaryContainer;
        break;
      case 2:
        page = DeletedPage();
        background = Theme.of(context).colorScheme.secondaryContainer;
      break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.delete),
                      label: Text('Deleted'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: background,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return Center(
      child: ListView(
        children: [
          for (var favorite in favorites)
            FavoritesCard(pair: favorite),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class DeletedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var deletedFavs = appState.deletedFavs;

    // Add a third screen to keep unfavorited pairs
    // Add functionality to refavorite
    // Add functionality to delete forever

    return Center(
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Re-favorite words pairs or deleted them forever"),
            ],
          ),
          for (var deletedFav in deletedFavs)
            DeletedCard(pair: deletedFav),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.displayMedium!.copyWith();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GradientText(
          pair, 
          style: style,
          gradient: LinearGradient(colors: rainbowColors),
        ),
      ),
    );
  }
}

class FavoritesCard extends StatelessWidget {
  const FavoritesCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context); 
    final style = theme.textTheme.bodyLarge!.copyWith();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                pair.asPascalCase, 
                style: style,
                semanticsLabel: "${pair.first} ${pair.second}",
              ),
            ),
            IconButton(
              onPressed: () {
                  appState.deleteFavorite(pair);
                }, 
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class DeletedCard extends StatelessWidget {
  const DeletedCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context); 
    final style = theme.textTheme.bodyLarge!.copyWith();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                pair.asPascalCase, 
                style: style,
                semanticsLabel: "${pair.first} ${pair.second}",
              ),
            ),
            IconButton(
              onPressed: () {
                  appState.toggleFavorite(pair);
                }, 
              icon: Icon(Icons.favorite),
            ),
            IconButton(
              onPressed: () {
                  appState.deleteForever(pair);
                }, 
              icon: Icon(Icons.delete_forever),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.pair, {
    required this.gradient,
    this.style,
  });

  final WordPair pair;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        pair.asPascalCase, 
        style: style,
        semanticsLabel: "${pair.first} ${pair.second}",
      ),
    );
  }
}
