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
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 227, 17)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var deletedFavorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void deleteFavorite() {
      favorites.remove(current);
      deletedFavorites.add(current);
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
                  appState.toggleFavorite();
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

    // Write a for loop or map that creates a small card per item in favorites
    // Add a favorite icon to the right of each small card
    // Add functionality to unfavorite from Favorites page

    return Center(
      child: ListView(
        children: [
          FavoritesCard(pair: favorites[0]),
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
    var deletedFavorites = appState.deletedFavorites;

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
          DeletedCard(pair: deletedFavorites[0]),
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
                  appState.deleteFavorite();
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
                  // re-favorite
                }, 
              icon: Icon(Icons.favorite),
            ),
            IconButton(
              onPressed: () {
                  // delete forever
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
