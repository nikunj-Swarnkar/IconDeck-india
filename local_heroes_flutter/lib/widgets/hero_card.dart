import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import '../utils/constants.dart';
import 'swipe_indicator.dart';

/// A swipeable hero card widget.
class HeroCard extends StatefulWidget {
  final LocalHero hero;
  final bool isActive;
  final Function(bool) onSwipe; // true = right (keep), false = left (pass)
  final VoidCallback? onTap;

  const HeroCard({
    super.key,
    required this.hero,
    required this.isActive,
    required this.onSwipe,
    this.onTap,
  });

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard>
    with TickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<Offset> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _returnAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.addListener(() {
      if (_animationController.isAnimating) {
        setState(() {
          _dragOffset = _returnAnimation.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isActive) return;
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isActive) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isActive) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25;

    if (_dragOffset.dx > threshold) {
      // Swipe right - Keep
      _animateOut(true);
    } else if (_dragOffset.dx < -threshold) {
      // Swipe left - Pass
      _animateOut(false);
    } else {
      // Return to center
      _returnToCenter();
    }

    setState(() {
      _isDragging = false;
    });
  }

  void _animateOut(bool isKeep) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isKeep ? screenWidth * 1.5 : -screenWidth * 1.5;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    final animation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(targetX, _dragOffset.dy),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    controller.addListener(() {
      setState(() {
        _dragOffset = animation.value;
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onSwipe(isKeep);
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _returnToCenter() {
    _returnAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0);
  }

  double get _rotationAngle {
    return _dragOffset.dx / 300 * 0.3; // Max ~17 degrees
  }

  double get _keepIndicatorOpacity {
    return (_dragOffset.dx / 150).clamp(0.0, 1.0);
  }

  double get _passIndicatorOpacity {
    return (-_dragOffset.dx / 150).clamp(0.0, 1.0);
  }

  Color get _overlayColor {
    if (_dragOffset.dx > 20) {
      return AppColors.keepGreen.withValues(alpha: (_dragOffset.dx / 300).clamp(0.0, 0.4));
    } else if (_dragOffset.dx < -20) {
      return AppColors.passRed.withValues(alpha: (-_dragOffset.dx / 300).clamp(0.0, 0.4));
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      child: Transform.translate(
        offset: widget.isActive ? _dragOffset : Offset.zero,
        child: Transform.rotate(
          angle: widget.isActive ? _rotationAngle : 0,
          child: Container(
            width: AppDimensions.cardMaxWidth,
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Main card content
                Column(
                  children: [
                    // Image section (55%)
                    Expanded(
                      flex: 55,
                      child: _buildImageSection(),
                    ),
                    // Content section (45%)
                    Expanded(
                      flex: 45,
                      child: _buildContentSection(),
                    ),
                  ],
                ),

                // Color overlay on swipe
                if (widget.isActive)
                  Positioned.fill(
                    child: Container(
                      color: _overlayColor,
                    ),
                  ),

                // Keep indicator
                if (widget.isActive)
                  Positioned(
                    top: 32,
                    left: 32,
                    child: SwipeIndicator(
                      isKeep: true,
                      opacity: _keepIndicatorOpacity,
                    ),
                  ),

                // Pass indicator
                if (widget.isActive)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: SwipeIndicator(
                      isKeep: false,
                      opacity: _passIndicatorOpacity,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image or placeholder
        widget.hero.imageUrl != null
            ? Image.network(
                widget.hero.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDBEAFE), // blue-100
            Color(0xFFC7D2FE), // indigo-200
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.hero.initials,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Color(0xFF818CF8), // indigo-400
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXL),
          topRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar circle
          Transform.translate(
            offset: const Offset(0, -40),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.hero.imageUrl != null
                  ? Image.network(
                      widget.hero.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          widget.hero.initials,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.hero.initials,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
            ),
          ),

          // Name and content - shifted up to compensate for avatar overlap
          Transform.translate(
            offset: const Offset(0, -28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.hero.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Field badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.hero.field.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569), // slate-600
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Bio - limited to 3 lines with ellipsis
                Text(
                  widget.hero.bio,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
