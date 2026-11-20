import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'services/film_engine/film_engine.dart';
import 'services/film_engine/lut_processor.dart';
import 'services/media/photo_service.dart';

void main() {
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
  final filmEngine = FilmEngine(lutProcessor: lutProcessor);
  final photoService = PhotoService();

  runApp(CheeseraApp(
    filmEngine: filmEngine,
    photoService: photoService,
  ));
}

class CheeseraApp extends StatelessWidget {
  final FilmEngine filmEngine;
  final PhotoService photoService;

  const CheeseraApp({
    super.key,
    required this.filmEngine,
    required this.photoService,
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
      ),
    );
  }
}
