import 'package:flutter/material.dart';
import 'screens/instant_editor_screen.dart';
import 'screens/disposable_camera_screen.dart';
import 'screens/recipe_vault_screen.dart';
import 'screens/help_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cheesera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE8E8E8),
          secondary: const Color(0xFFB8B8B8),
          surface: const Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D0D),
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFFE8E8E8),
          unselectedItemColor: Color(0xFF5A5A5A),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w300,
            letterSpacing: 0.3,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _showHelp = false;

  final List<Widget> _screens = [
    const InstantEditorScreen(),
    const DisposableCameraScreen(),
    const RecipeVaultScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleHelp() {
    setState(() {
      _showHelp = !_showHelp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_showHelp)
            HelpPage(
              onClose: _toggleHelp,
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey[800]!,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note),
              label: 'Editor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Vault',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: _toggleHelp,
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        child: Icon(
          Icons.help_outline,
          color: Colors.grey[300],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
