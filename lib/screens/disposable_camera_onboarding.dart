import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisposableCameraOnboarding extends StatefulWidget {
  final VoidCallback onDismiss;

  const DisposableCameraOnboarding({
    super.key,
    required this.onDismiss,
  });

  @override
  State<DisposableCameraOnboarding> createState() =>
      _DisposableCameraOnboardingState();
}

class _DisposableCameraOnboardingState
    extends State<DisposableCameraOnboarding> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.camera_alt,
      title: 'Disposable Camera',
      description:
          'Welcome to your digital disposable camera. Just like the real thing, you have 27 exposures. Make them count!',
      highlight: '27 Exposures',
    ),
    OnboardingPage(
      icon: Icons.camera,
      title: 'Retro Viewfinder',
      description:
          'Frame your shots with the classic viewfinder overlay. The corner brackets and crosshair help you compose perfect photos.',
      highlight: 'Classic Look',
    ),
    OnboardingPage(
      icon: Icons.circle,
      title: 'Plastic Shutter',
      description:
          'Tap the large shutter button to capture. Watch for the flash effect that confirms your shot was taken.',
      highlight: 'Tap to Capture',
    ),
    OnboardingPage(
      icon: Icons.hourglass_empty,
      title: 'Developing Queue',
      description:
          'Photos take 2 hours to develop. Check the queue by tapping the gallery icon. See the countdown timer for each photo.',
      highlight: '2 Hour Wait',
    ),
    OnboardingPage(
      icon: Icons.phone_iphone,
      title: 'Shake to Develop',
      description:
          'Can\'t wait? In the queue view, shake your device to instantly develop photos! Just like instant film.',
      highlight: 'Shake It!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disposable_camera_onboarding_seen', true);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _markAsSeen();
      widget.onDismiss();
    }
  }

  void _skip() {
    _markAsSeen();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? Colors.grey[300]
                        : Colors.grey[700],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Next/Done button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8E8E8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.grey[100],
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE8E8E8).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              page.highlight,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[300],
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.grey[400],
              height: 1.5,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final String highlight;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.highlight,
  });
}
