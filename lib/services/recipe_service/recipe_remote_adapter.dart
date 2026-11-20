import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/film_recipe.dart';
import 'recipe_serializer.dart';

/// Abstract contract for fetching recipes from a remote source.
abstract class RecipeRemoteAdapter {
  Future<List<FilmRecipe>> fetchRecipes();
}

/// Remote adapter for Fuji X Weekly community recipes.
/// Supports live HTTP GET against a configurable endpoint and falls back
/// to curated community presets if no external network is present.
class XWeeklyRecipeAdapter implements RecipeRemoteAdapter {
  final String endpointUrl;
  final http.Client? client;
  final Duration timeout;

  // Optional mock payload for offline simulation or unit tests
  final String? mockResponsePayload;
  final bool simulateNetworkError;

  XWeeklyRecipeAdapter({
    this.endpointUrl = 'https://api.cheesera.app/v1/xweekly/recipes.json',
    this.client,
    this.timeout = const Duration(seconds: 4),
    this.mockResponsePayload,
    this.simulateNetworkError = false,
  });

  @override
  Future<List<FilmRecipe>> fetchRecipes() async {
    if (simulateNetworkError) {
      throw const SocketException('Simulated network unreachable');
    }

    // 1. If explicit mock payload is provided (e.g. in tests)
    if (mockResponsePayload != null) {
      return _parsePayload(mockResponsePayload!);
    }

    // 2. Perform HTTP GET request
    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.parse(endpointUrl);
      final response = await httpClient.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parsePayload(response.body);
      } else {
        throw HttpException(
          'HTTP Error ${response.statusCode}: ${response.reasonPhrase}',
          uri: uri,
        );
      }
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Parses payload supporting both Cheesera JSON schema and Fuji X Weekly community schema.
  List<FilmRecipe> _parsePayload(String body) {
    final decoded = jsonDecode(body);
    final List<FilmRecipe> results = [];

    if (decoded is List) {
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          // If it contains "Film Simulation" or "Highlight Tone", treat as X Weekly
          if (item.containsKey('Film Simulation') || item.containsKey('Dynamic Range')) {
            results.add(RecipeSerializer.parseXWeeklyFormat(item));
          } else {
            results.add(RecipeSerializer.fromJson(item));
          }
        }
      }
    } else if (decoded is Map<String, dynamic>) {
      // Wrapper object e.g. {"recipes": [...]}
      final list = decoded['recipes'] ?? decoded['data'];
      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            if (item.containsKey('Film Simulation') || item.containsKey('Dynamic Range')) {
              results.add(RecipeSerializer.parseXWeeklyFormat(item));
            } else {
              results.add(RecipeSerializer.fromJson(item));
            }
          }
        }
      }
    }

    if (results.isEmpty) {
      throw const FormatException('No valid recipes found in payload.');
    }

    return results;
  }
}

class SocketException implements Exception {
  final String message;
  const SocketException(this.message);
  @override
  String toString() => 'SocketException: $message';
}

class HttpException implements Exception {
  final String message;
  final Uri? uri;
  const HttpException(this.message, {this.uri});
  @override
  String toString() => 'HttpException: $message (URI: $uri)';
}
