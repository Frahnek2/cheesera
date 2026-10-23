import 'package:flutter/material.dart';

class RecipeVaultScreen extends StatelessWidget {
  const RecipeVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Recipe Vault',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.grey[200],
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your curated collection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w200,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
