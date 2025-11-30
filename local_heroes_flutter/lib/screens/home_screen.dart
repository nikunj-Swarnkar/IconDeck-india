import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/heroes_provider.dart';
import '../utils/constants.dart';
import '../widgets/hero_card.dart';
import '../widgets/swipe_indicator.dart';
import '../widgets/custom_button.dart';
import 'kept_list_screen.dart';

/// Home screen with the main swipe interface.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<HeroesProvider>(
        builder: (context, provider, _) {
          // Trigger confetti when needed
          if (provider.showConfetti) {
            _confettiController.play();
          }

          return Stack(
            children: [
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    _buildHeader(context, provider),

                    // Main area
                    Expanded(
                      child: provider.isFinished
                          ? _buildFinishedState(context, provider)
                          : _buildCardStack(context, provider),
                    ),

                    // Navigation bar
                    _buildNavBar(context, provider),
                  ],
                ),
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: AppColors.confettiColors,
                  numberOfParticles: 30,
                  gravity: 0.2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HeroesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and title
          Row(
            children: [
              _buildAppLogo(),
              const SizedBox(width: 12),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Kept button
          GestureDetector(
            onTap: () => _openKeptList(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    AppStrings.keep,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.keepGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.keepGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.keptList.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.keepGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_outline,
        size: 24,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCardStack(BuildContext context, HeroesProvider provider) {
    final visibleCards = provider.visibleCards;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cards - render from bottom to top
                for (int i = 0; i < visibleCards.length; i++)
                  Positioned(
                    child: Transform.scale(
                      scale: i == visibleCards.length - 1 ? 1.0 : 0.95,
                      child: HeroCard(
                        hero: visibleCards[i],
                        isActive: i == visibleCards.length - 1,
                        onSwipe: (isKeep) {
                          provider.onSwipe(
                            isKeep
                                ? SwipeDirection.right
                                : SwipeDirection.left,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Swipe hints and undo button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL,
            vertical: AppDimensions.paddingMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SwipeHints(),
              
              // Undo button in center
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: provider.canUndo ? provider.undo : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: provider.canUndo
                            ? AppColors.surfaceDark
                            : AppColors.surfaceDark.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.undo,
                        size: 20,
                        color: provider.canUndo
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinishedState(BuildContext context, HeroesProvider provider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.paddingLG),
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.deckComplete,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.heroesKept.replaceAll(
                '{count}',
                '${provider.keptList.length}',
              ),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: AppStrings.restartDeck,
              variant: ButtonVariant.secondary,
              fullWidth: true,
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: provider.restart,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: AppStrings.viewKeptList,
              variant: ButtonVariant.primary,
              fullWidth: true,
              icon: const Icon(Icons.bookmark_outline, size: 18),
              onPressed: () => _openKeptList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, HeroesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.layers_outlined,
            label: AppStrings.deck,
            onTap: provider.restart,
          ),
          _buildNavItem(
            icon: Icons.bookmark_outline,
            label: AppStrings.keptList,
            onTap: () => _openKeptList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: AppColors.textMuted),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _openKeptList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const KeptListScreen(),
      ),
    );
  }
}
