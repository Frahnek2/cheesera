import '../models/recipe.dart';
import 'image_analyzer.dart';

class RecipeRecommendation {
  final Recipe recipe;
  final double matchScore;
  final List<String> matchedTags;

  RecipeRecommendation({
    required this.recipe,
    required this.matchScore,
    required this.matchedTags,
  });
}

class RecipeRecommender {
  /// Recommend recipes based on image analysis tags
  static List<RecipeRecommendation> recommendRecipes(
    ImageAnalysisResult analysis,
    List<Recipe> recipes,
  ) {
    List<RecipeRecommendation> recommendations = [];

    for (var recipe in recipes) {
      final matchScore = _calculateMatchScore(analysis.tags, recipe.tags);
      final matchedTags = _getMatchedTags(analysis.tags, recipe.tags);

      recommendations.add(RecipeRecommendation(
        recipe: recipe,
        matchScore: matchScore,
        matchedTags: matchedTags,
      ));
    }

    // Sort by match score (highest first)
    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return recommendations;
  }

  /// Calculate match score between image tags and recipe tags
  static double _calculateMatchScore(List<String> imageTags, List<String> recipeTags) {
    if (recipeTags.isEmpty) return 0.0;

    double weightedScore = 0.0;

    // Weight mapping for important tags
    final Map<String, double> tagWeights = {
      'golden hour': 2.0,
      'moody urban': 1.8,
      'high contrast': 1.5,
      'low contrast': 1.5,
      'vibrant': 1.3,
      'muted': 1.3,
      'warm': 1.2,
      'cool': 1.2,
      'cinematic': 1.5,
      'vintage': 1.4,
      'soft': 1.1,
      'portrait': 1.3,
      'landscape': 1.3,
      'street': 1.2,
    };

    for (var imageTag in imageTags) {
      for (var recipeTag in recipeTags) {
        // Direct match
        if (imageTag.toLowerCase() == recipeTag.toLowerCase()) {
          weightedScore += tagWeights[imageTag.toLowerCase()] ?? 1.0;
        }
        // Partial match (e.g., "moody" matches "moody urban")
        else if (imageTag.toLowerCase().contains(recipeTag.toLowerCase()) ||
                 recipeTag.toLowerCase().contains(imageTag.toLowerCase())) {
          weightedScore += (tagWeights[imageTag.toLowerCase()] ?? 1.0) * 0.5;
        }
      }
    }

    // Normalize score
    final maxPossibleScore = recipeTags.length * 2.0; // Approximate max
    return (weightedScore / maxPossibleScore).clamp(0.0, 1.0);
  }

  /// Get list of tags that matched between image and recipe
  static List<String> _getMatchedTags(List<String> imageTags, List<String> recipeTags) {
    List<String> matched = [];

    for (var imageTag in imageTags) {
      for (var recipeTag in recipeTags) {
        if (imageTag.toLowerCase() == recipeTag.toLowerCase() ||
            imageTag.toLowerCase().contains(recipeTag.toLowerCase()) ||
            recipeTag.toLowerCase().contains(imageTag.toLowerCase())) {
          if (!matched.contains(recipeTag)) {
            matched.add(recipeTag);
          }
        }
      }
    }

    return matched;
  }

  /// Get the top recommendation
  static RecipeRecommendation? getTopRecommendation(
    ImageAnalysisResult analysis,
    List<Recipe> recipes,
  ) {
    final recommendations = recommendRecipes(analysis, recipes);
    return recommendations.isNotEmpty ? recommendations.first : null;
  }
}
