import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'services/film_engine/film_engine.dart';
import 'services/film_engine/lut_manager.dart';
import 'services/film_engine/lut_processor.dart';
import 'services/media/photo_service.dart';
import 'services/recipe_service/recipe_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive darkroom status bar & navigation styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0E11),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait for tactile one-handed camera operation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final lutProcessor = const DefaultLutProcessor();
  final lutManager = LutManager(lutProcessor: lutProcessor);
  final filmEngine = FilmEngine(lutProcessor: lutProcessor, lutManager: lutManager);
  final photoService = PhotoService();

  final recipeProvider = RecipeProvider();
  // Initialize offline cache and start remote background sync
  recipeProvider.initialize();

  runApp(CheeseraApp(
    filmEngine: filmEngine,
    photoService: photoService,
    recipeProvider: recipeProvider,
  ));
}

class CheeseraApp extends StatelessWidget {
  final FilmEngine filmEngine;
  final PhotoService photoService;
  final RecipeProvider recipeProvider;

  const CheeseraApp({
    super.key,
    required this.filmEngine,
    required this.photoService,
    required this.recipeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cheesera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(
        filmEngine: filmEngine,
        photoService: photoService,
        recipeProvider: recipeProvider,
      ),
    );
  }
}
