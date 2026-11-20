import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../models/film_recipe.dart';
import '../../../../services/recipe_service/recipe_provider.dart';
import '../../../../widgets/tactile_button.dart';

/// Modal sheet displaying recipes from RecipeProvider with X Weekly remote sync status,
/// tabs for Built-In, Community, and Custom recipes, and delete capability.
class RecipeCatalogSheet extends StatefulWidget {
  final RecipeProvider recipeProvider;
  final ValueChanged<FilmRecipe>? onSelectRecipe;

  const RecipeCatalogSheet({
    super.key,
    required this.recipeProvider,
    this.onSelectRecipe,
  });

  @override
  State<RecipeCatalogSheet> createState() => _RecipeCatalogSheetState();
}

class _RecipeCatalogSheetState extends State<RecipeCatalogSheet> {
  int _activeTab = 0; // 0: All, 1: Built-in, 2: Community (X Weekly), 3: My Custom

  @override
  void initState() {
    super.initState();
    widget.recipeProvider.addListener(_onProviderUpdate);
  }

  @override
  void dispose() {
    widget.recipeProvider.removeListener(_onProviderUpdate);
    super.dispose();
  }

  void _onProviderUpdate() {
    if (mounted) setState(() {});
  }

  List<FilmRecipe> get _filteredRecipes {
    final provider = widget.recipeProvider;
    switch (_activeTab) {
      case 1:
        return provider.builtInRecipes;
      case 2:
        return provider.communityRecipes;
      case 3:
        return provider.customRecipes;
      default:
        return provider.recipes;
    }
  }

  String _getSyncStatusText(RecipeSyncStatus status) {
    switch (status) {
      case RecipeSyncStatus.syncing:
        return 'SYNCING WITH XWEEKLY...';
      case RecipeSyncStatus.success:
        return 'SYNCED (XWEEKLY)';
      case RecipeSyncStatus.offlineFallback:
        return 'OFFLINE CACHE ACTIVE';
      case RecipeSyncStatus.error:
        return 'SYNC FAILED (OFFLINE)';
      case RecipeSyncStatus.idle:
        return 'VAULT READY';
    }
  }

  Color _getSyncStatusColor(RecipeSyncStatus status) {
    switch (status) {
      case RecipeSyncStatus.syncing:
        return AppColors.cinestillCyan;
      case RecipeSyncStatus.success:
        return AppColors.amberAccent;
      case RecipeSyncStatus.offlineFallback:
        return AppColors.textSecondary;
      case RecipeSyncStatus.error:
        return AppColors.filmRed;
      case RecipeSyncStatus.idle:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.recipeProvider;
    final recipes = _filteredRecipes;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECIPE VAULT',
                        style: AppTypography.filmHeadline.copyWith(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getSyncStatusColor(provider.syncStatus),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getSyncStatusText(provider.syncStatus),
                            style: AppTypography.filmMetadata.copyWith(
                              fontSize: 8,
                              color: _getSyncStatusColor(provider.syncStatus),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Refresh button
                  TactileButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 8,
                    onPressed: () {
                      HapticsUtil.selectionTick();
                      provider.refreshFromRemote();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync_rounded, size: 14, color: AppColors.amberAccent),
                        const SizedBox(width: 4),
                        Text(
                          'SYNC',
                          style: AppTypography.filmMetadata.copyWith(
                            fontSize: 9,
                            color: AppColors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab('ALL', 0),
                  const SizedBox(width: 6),
                  _buildTab('BUILT-IN', 1),
                  const SizedBox(width: 6),
                  _buildTab('XWEEKLY', 2),
                  const SizedBox(width: 6),
                  _buildTab('CUSTOM', 3),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceBorder, height: 16),

            // Recipe List
            Expanded(
              child: recipes.isEmpty
                  ? Center(
                      child: Text(
                        'No recipes in this category.',
                        style: AppTypography.caption,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _buildRecipeCard(recipe);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int idx) {
    final active = _activeTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticsUtil.selectionTick();
          setState(() => _activeTab = idx);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: active ? AppColors.surfaceHighlight : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: active ? AppColors.amberAccent : AppColors.surfaceBorder),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTypography.filmMetadata.copyWith(
                fontSize: 8,
                color: active ? AppColors.amberAccent : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(FilmRecipe recipe) {
    return GestureDetector(
      onTap: () {
        HapticsUtil.lightSnap();
        if (widget.onSelectRecipe != null) {
          widget.onSelectRecipe!(recipe);
        }
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: recipe.preset.badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recipe.title.toUpperCase(),
                    style: AppTypography.filmHeadline.copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (recipe.isCustom && !recipe.id.startsWith('xweekly_'))
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.filmRed),
                    onPressed: () {
                      HapticsUtil.lightSnap();
                      widget.recipeProvider.deleteCustomRecipe(recipe.id);
                    },
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    recipe.preset.code,
                    style: AppTypography.filmMetadata.copyWith(
                      fontSize: 8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (recipe.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                recipe.notes!,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildTag(recipe.dynamicRange),
                _buildTag('H: ${recipe.highlightTone >= 0 ? '+' : ''}${recipe.highlightTone}'),
                _buildTag('S: ${recipe.shadowTone >= 0 ? '+' : ''}${recipe.shadowTone}'),
                if (recipe.customLutId != null) _buildTag('3D .CUBE'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
      ),
      child: Text(
        text,
        style: AppTypography.filmMetadata.copyWith(fontSize: 8, color: AppColors.textTertiary),
      ),
    );
  }
}
