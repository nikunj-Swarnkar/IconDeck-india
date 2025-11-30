import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hero_model.dart';
import '../data/heroes_data.dart';

/// Enum for swipe direction.
enum SwipeDirection { left, right }

/// History item for undo functionality.
class HistoryItem {
  final int index;
  final SwipeDirection direction;
  final String heroId;

  const HistoryItem({
    required this.index,
    required this.direction,
    required this.heroId,
  });
}

/// Provider for managing heroes state.
class HeroesProvider extends ChangeNotifier {
  List<LocalHero> _deck = [];
  List<LocalHero> _keptList = [];
  List<HistoryItem> _history = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showConfetti = false;

  // Getters
  List<LocalHero> get deck => _deck;
  List<LocalHero> get keptList => _keptList;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get showConfetti => _showConfetti;
  bool get isFinished => _currentIndex >= _deck.length;
  bool get canUndo => _history.isNotEmpty;

  /// Get the current visible cards (top 2 for stack effect).
  List<LocalHero> get visibleCards {
    if (_currentIndex >= _deck.length) return [];
    final endIndex = (_currentIndex + 2).clamp(0, _deck.length);
    return _deck.sublist(_currentIndex, endIndex);
  }

  /// Initialize the deck with heroes data.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay (like the React app's splash screen)
    await Future.delayed(const Duration(milliseconds: 2000));

    _deck = List.from(initialHeroes);
    _currentIndex = 0;
    _history = [];
    _isLoading = false;
    notifyListeners();
  }

  /// Handle card swipe.
  void onSwipe(SwipeDirection direction) {
    if (_currentIndex >= _deck.length) return;

    final currentHero = _deck[_currentIndex];

    // Add to history
    _history.add(HistoryItem(
      index: _currentIndex,
      direction: direction,
      heroId: currentHero.id,
    ));

    // If swiped right (keep), add to kept list
    if (direction == SwipeDirection.right) {
      // Check if not already in kept list
      if (!_keptList.any((h) => h.id == currentHero.id)) {
        _keptList.insert(
          0,
          currentHero.copyWith(keptAt: DateTime.now()),
        );
        _triggerConfetti();
        // Haptic feedback
        HapticFeedback.mediumImpact();
      }
    } else {
      // Light haptic for pass
      HapticFeedback.lightImpact();
    }

    _currentIndex++;
    notifyListeners();
  }

  /// Undo the last swipe.
  void undo() {
    if (_history.isEmpty) return;

    final lastAction = _history.removeLast();

    // Decrement index
    _currentIndex = (_currentIndex - 1).clamp(0, _deck.length);

    // If it was a keep, remove from kept list
    if (lastAction.direction == SwipeDirection.right) {
      _keptList.removeWhere((h) => h.id == lastAction.heroId);
    }

    HapticFeedback.lightImpact();
    notifyListeners();
  }

  /// Restart the deck.
  void restart() {
    _currentIndex = 0;
    _history = [];
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  /// Remove a hero from the kept list.
  void removeFromKeptList(String id) {
    _keptList.removeWhere((h) => h.id == id);
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  /// Clear all kept heroes.
  void clearAllKept() {
    _keptList = [];
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  /// Trigger confetti animation.
  void _triggerConfetti() {
    _showConfetti = true;
    notifyListeners();

    // Reset after animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      _showConfetti = false;
      notifyListeners();
    });
  }

  /// Search kept list.
  List<LocalHero> searchKeptList(String query) {
    if (query.isEmpty) return _keptList;

    final lowerQuery = query.toLowerCase();
    return _keptList.where((hero) {
      return hero.name.toLowerCase().contains(lowerQuery) ||
          hero.field.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
