import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../services/image_analyzer.dart';
import '../services/recipe_recommender.dart';

class InstantEditorScreen extends StatefulWidget {
  const InstantEditorScreen({super.key});

  @override
  State<InstantEditorScreen> createState() => _InstantEditorScreenState();
}

class _InstantEditorScreenState extends State<InstantEditorScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  RecipeRecommendation? _recommendation;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isAnalyzing = true;
        _recommendation = null;
      });

      // Analyze the image
      try {
        final imageBytes = await _selectedImage!.readAsBytes();
        final analysis = await ImageAnalyzer.analyzeImage(imageBytes);
        
        final recipes = Recipe.getSampleRecipes();
        final recommendation = RecipeRecommender.getTopRecommendation(
          analysis,
          recipes,
        );

        setState(() {
          _isAnalyzing = false;
          _recommendation = recommendation;
        });
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error analyzing image: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Instant Editor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[200],
                      letterSpacing: 2,
                    ),
                  ),
                  if (_selectedImage != null)
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.grey[400]),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _recommendation = null;
                        });
                      },
                    ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: _selectedImage == null
                  ? _buildEmptyState()
                  : _buildImageEditor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Import a photo',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.grey[200],
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We\'ll analyze it and suggest a recipe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w200,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImportButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 24),
              _buildImportButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[700]!),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildImageEditor() {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Analysis results
        if (_isAnalyzing)
          _buildAnalyzingIndicator()
        else if (_recommendation != null)
          _buildRecommendation(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAnalyzingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing image...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.grey[400],
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggested Vibe Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE8E8E8).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 8),
                Text(
                  'Suggested Vibe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[300],
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recipe name
          Text(
            _recommendation!.recipe.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.grey[100],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // Recipe description
          Text(
            _recommendation!.recipe.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Matched tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recommendation!.matchedTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[300],
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Match score
          Text(
            'Match: ${(_recommendation!.matchScore * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w200,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
