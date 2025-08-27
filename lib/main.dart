import 'package:flutter/material.dart';
import 'menu/home.dart';
import 'menu/search.dart';
import 'menu/watchlist.dart';
import 'menu/movie_detail.dart';
import 'navigasi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/search': (context) => const Search(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/movie-detail') {
          final movieId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => MovieDetail(movieId: movieId),
          );
        }
        return null;
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Home(),
    const Search(),
    const Watchlist(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Navigasi(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
