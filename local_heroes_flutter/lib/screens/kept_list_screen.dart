import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hero_model.dart';
import '../providers/heroes_provider.dart';
import '../utils/constants.dart';
import '../utils/csv_export.dart';
import '../widgets/custom_button.dart';
import 'hero_detail_screen.dart';

/// Screen displaying the list of kept heroes.
class KeptListScreen extends StatefulWidget {
  const KeptListScreen({super.key});

  @override
  State<KeptListScreen> createState() => _KeptListScreenState();
}

class _KeptListScreenState extends State<KeptListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isConfirmingClear = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Consumer<HeroesProvider>(
          builder: (context, provider, _) {
            return Text(
              '${AppStrings.keptList} (${provider.keptList.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
      ),
      body: Consumer<HeroesProvider>(
        builder: (context, provider, _) {
          final filteredList = provider.searchKeptList(_searchQuery);

          return Column(
            children: [
              // Search bar
              _buildSearchBar(),

              // List
              Expanded(
                child: provider.keptList.isEmpty
                    ? _buildEmptyState()
                    : filteredList.isEmpty
                        ? _buildNoResultsState()
                        : _buildList(filteredList, provider),
              ),

              // Footer with actions
              _buildFooter(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      color: AppColors.background,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search by name or field...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textMuted,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_outline,
              size: 32,
              color: AppColors.textMuted.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noHeroesKept,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              AppStrings.swipeRightToKeep,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Text(
        'No matches found for "$_searchQuery"',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildList(List<LocalHero> heroes, HeroesProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      itemCount: heroes.length,
      itemBuilder: (context, index) {
        final hero = heroes[index];
        return _buildHeroItem(context, hero, provider);
      },
    );
  }

  Widget _buildHeroItem(
    BuildContext context,
    LocalHero hero,
    HeroesProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HeroDetailScreen(hero: hero),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.border,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: hero.imageUrl != null
                  ? Image.network(
                      hero.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          hero.initials,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        hero.initials,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hero.field,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                // Learn more button
                _buildActionButton(
                  icon: Icons.info_outline,
                  label: 'View',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HeroDetailScreen(hero: hero),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Remove button
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: 'Remove',
                  color: AppColors.passRed,
                  onTap: () => provider.removeFromKeptList(hero.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 12, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, HeroesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Clear all button
          Expanded(
            child: CustomButton(
              text: _isConfirmingClear ? 'Confirm?' : AppStrings.clearAll,
              variant: _isConfirmingClear
                  ? ButtonVariant.danger
                  : ButtonVariant.dangerOutline,
              icon: Icon(
                _isConfirmingClear
                    ? Icons.warning_amber_rounded
                    : Icons.delete_outline,
                size: 18,
              ),
              onPressed: provider.keptList.isEmpty
                  ? null
                  : () {
                      if (_isConfirmingClear) {
                        provider.clearAllKept();
                        setState(() {
                          _isConfirmingClear = false;
                        });
                      } else {
                        setState(() {
                          _isConfirmingClear = true;
                        });
                        // Auto-reset after 3 seconds
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            setState(() {
                              _isConfirmingClear = false;
                            });
                          }
                        });
                      }
                    },
            ),
          ),
          const SizedBox(width: 12),
          // Export button
          Expanded(
            flex: 2,
            child: CustomButton(
              text: AppStrings.exportCsv,
              variant: ButtonVariant.primary,
              icon: const Icon(Icons.download, size: 18),
              onPressed: provider.keptList.isEmpty
                  ? null
                  : () => CsvExport.exportAndShare(provider.keptList),
            ),
          ),
        ],
      ),
    );
  }
}
