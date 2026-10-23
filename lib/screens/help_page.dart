import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  final VoidCallback onClose;

  const HelpPage({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[300]),
          onPressed: onClose,
        ),
        title: Text(
          'Help',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.grey[200],
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            'Instant Editor',
            Icons.edit_note,
            [
              _buildFeature(
                'Import Photos',
                'Tap "Camera" or "Gallery" to import photos from your device.',
              ),
              _buildFeature(
                'AI Analysis',
                'The app analyzes your photo locally to detect brightness, contrast, color temperature, and saturation.',
              ),
              _buildFeature(
                'Recipe Recommendations',
                'Based on the analysis, the app suggests the best Fujifilm recipe for your photo.',
              ),
              _buildFeature(
                'Match Score',
                'See how well each recipe matches your photo with a percentage score.',
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Disposable Camera',
            Icons.camera_alt,
            [
              _buildFeature(
                '27 Exposures',
                'Like a real disposable camera, you have 27 shots. Make them count!',
              ),
              _buildFeature(
                'Retro Viewfinder',
                'Frame your shots with the classic corner brackets and crosshair overlay.',
              ),
              _buildFeature(
                'Plastic Shutter',
                'Tap the large circular shutter button to capture. Watch for the flash effect.',
              ),
              _buildFeature(
                'Developing Queue',
                'Photos take 2 hours to develop. Check the queue by tapping the gallery icon.',
              ),
              _buildFeature(
                'Shake to Develop',
                'In the queue view, shake your device to instantly develop photos!',
              ),
              _buildFeature(
                'Countdown Timer',
                'See how much time remains until each photo is ready to develop.',
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Recipe Vault',
            Icons.menu_book,
            [
              _buildFeature(
                'Fujifilm Recipes',
                'Browse a collection of authentic Fujifilm film simulation recipes.',
              ),
              _buildFeature(
                'Recipe Details',
                'Each recipe includes film simulation, dynamic range, color settings, and more.',
              ),
              _buildFeature(
                'Tags',
                'Recipes are tagged with aesthetic descriptions like "moody", "vibrant", "cinematic".',
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Tips & Tricks',
            Icons.lightbulb_outline,
            [
              _buildFeature(
                'Golden Hour',
                'Photos taken during golden hour will match warm-toned recipes better.',
              ),
              _buildFeature(
                'High Contrast',
                'Dramatic, high-contrast photos work well with Acros or Classic Chrome.',
              ),
              _buildFeature(
                'Soft Light',
                'Soft, low-contrast photos pair beautifully with Astia or Eterna.',
              ),
              _buildFeature(
                'Save Your Work',
                'Developed photos are saved to your device\'s storage.',
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Privacy',
            Icons.lock_outline,
            [
              _buildFeature(
                'Local Processing',
                'All image analysis happens on your device. No data is sent to external servers.',
              ),
              _buildFeature(
                'No API Keys',
                'No cloud services or API keys required. Everything works offline.',
              ),
              _buildFeature(
                'Secure Storage',
                'Your photos are stored locally on your device.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Colors.grey[200],
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFeature(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey[200],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.grey[400],
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
