# Local Heroes Flutter App

A Flutter mobile application showcasing local changemakers and unsung heroes in the community. Built for a competition with the theme **"Local Heroes - Showcasing local changemakers or unsung heroes in the community"**.

## 🎯 Competition Theme

This app celebrates everyday heroes who make a difference in their communities:
- Teachers going beyond their duties
- Community health workers
- Environmental activists
- Youth volunteers
- Social workers
- Local artists preserving culture
- Sports coaches nurturing talent
- And many more...

## ✨ Features

### Card Swipe Interface
- **Swipe Right** to "Keep" a hero in your collection
- **Swipe Left** to "Pass" and move to the next hero
- Visual indicators (green checkmark for keep, red X for pass)
- Color overlays during swipe for intuitive feedback
- Haptic feedback for swipe actions

### Kept List
- View all saved heroes
- Search functionality by name or field
- Remove individual heroes
- Export to CSV for sharing
- Clear all function with confirmation

### Hero Profiles
- Detailed hero information
- Contact/location information
- Community impact section
- Beautiful gradient backgrounds

### Design
- Dark theme with orange accent colors
- Modern, clean UI aesthetic
- Responsive for different screen sizes
- Confetti celebration effect when keeping heroes

## 📱 Screenshots

| Splash Screen | Home Screen | Card Swipe |
|--------------|-------------|------------|
| Loading animation | Card stack | Swipe gestures |

| Kept List | Hero Detail | Deck Complete |
|-----------|-------------|---------------|
| Search & manage | Full profile | Restart option |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/local-heroes-flutter.git
cd local-heroes-flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build for Release

Android:
```bash
flutter build apk --release
```

iOS:
```bash
flutter build ios --release
```

## 📁 Project Structure

```
local_heroes_flutter/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   └── hero_model.dart          # Hero data model
│   ├── screens/
│   │   ├── splash_screen.dart       # Splash/loading screen
│   │   ├── home_screen.dart         # Main swipe interface
│   │   ├── hero_detail_screen.dart  # Full hero profile view
│   │   └── kept_list_screen.dart    # Saved heroes list
│   ├── widgets/
│   │   ├── hero_card.dart           # Swipeable card widget
│   │   ├── swipe_indicator.dart     # Keep/Pass visual indicators
│   │   └── custom_button.dart       # Reusable button widget
│   ├── data/
│   │   └── heroes_data.dart         # Sample local heroes data
│   ├── providers/
│   │   └── heroes_provider.dart     # State management
│   └── utils/
│       ├── constants.dart           # Colors, styles, etc.
│       └── csv_export.dart          # Export functionality
├── assets/
│   └── images/                      # Local hero images
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_card_swiper | ^7.0.0 | Card swipe functionality |
| provider | ^6.0.0 | State management |
| share_plus | ^7.0.0 | Share functionality |
| path_provider | ^2.0.0 | File system access |
| csv | ^5.0.0 | CSV export |
| confetti | ^0.7.0 | Celebration effect |
| cached_network_image | ^3.3.0 | Image caching |
| url_launcher | ^6.0.0 | Open links |

## 🎨 Design Specifications

- **Background**: Dark (#1A1A1A)
- **Primary Color**: Orange gradient (#FB923C to #EA580C)
- **Keep Color**: Green (#22C55E)
- **Pass Color**: Red (#EF4444)
- **Card Background**: White
- **Border Radius**: 24px (cards), 12px (buttons)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the original React/TypeScript IconDeck-India web application
- Built for the "Local Heroes" themed competition
- Thanks to all the unsung heroes who inspire us every day

---

Made with ❤️ for celebrating local community heroes
