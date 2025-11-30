# Assets Directory

This directory contains image assets for local heroes.

## Adding Images

To add images for local heroes:

1. Add image files to this directory (PNG, JPG, or JPEG format)
2. Update the `imageUrl` field in `lib/data/heroes_data.dart` to reference the asset:

```dart
const LocalHero(
  id: '1',
  name: 'Hero Name',
  field: 'Field',
  bio: 'Bio text...',
  imageUrl: 'assets/images/hero_name.jpg',  // Local asset path
  contactInfo: 'Contact info...',
),
```

3. Ensure the image is listed in `pubspec.yaml` under `flutter.assets`

## Image Guidelines

- Recommended size: 600x600 pixels or larger
- Aspect ratio: Square or portrait (3:4)
- Format: PNG or JPG
- File size: Keep under 500KB for optimal performance
