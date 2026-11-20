import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'services/darkroom/darkroom_service.dart';
import 'services/external_media/media_source_adapter.dart';
import 'services/film_engine/film_engine.dart';
import 'services/film_engine/lut_manager.dart';
import 'services/film_engine/lut_processor.dart';
import 'services/llm/default_llm_curation_service.dart';
import 'services/media/photo_service.dart';
import 'services/recipe_service/recipe_provider.dart';
import 'services/watched_folder/watched_folder_service.dart';

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
  await recipeProvider.initialize();

  final darkroomService = DarkroomService();
  await darkroomService.initialize();

  const mediaAdapter = PlatformMediaSourceAdapter();

  final watchedFolderService = WatchedFolderService(recipeProvider: recipeProvider);
  await watchedFolderService.initialize();

  final llmService = DefaultLlmCurationService();

  runApp(CheeseraApp(
    filmEngine: filmEngine,
    photoService: photoService,
    recipeProvider: recipeProvider,
    darkroomService: darkroomService,
    watchedFolderService: watchedFolderService,
    mediaAdapter: mediaAdapter,
    llmService: llmService,
  ));
}

class CheeseraApp extends StatelessWidget {
  final FilmEngine filmEngine;
  final PhotoService photoService;
  final RecipeProvider recipeProvider;
  final DarkroomService darkroomService;
  final WatchedFolderService watchedFolderService;
  final MediaSourceAdapter mediaAdapter;
  final DefaultLlmCurationService llmService;

  const CheeseraApp({
    super.key,
    required this.filmEngine,
    required this.photoService,
    required this.recipeProvider,
    required this.darkroomService,
    required this.watchedFolderService,
    required this.mediaAdapter,
    required this.llmService,
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
        darkroomService: darkroomService,
        watchedFolderService: watchedFolderService,
        mediaAdapter: mediaAdapter,
        llmService: llmService,
      ),
    );
  }
}
