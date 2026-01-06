# Quick Start Guide

## Initial Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   
   For Web:
   ```bash
   flutter run -d chrome
   ```
   
   For Android:
   ```bash
   flutter run -d android
   ```
   
   For iOS:
   ```bash
   flutter run -d ios
   ```

## Project Overview

### Routes
- `/` - Home screen
- `/cfp` - Call for Papers submission
- `/speakers` - Speakers directory
- `/agenda` - Event schedule
- `/feedback` - Feedback collection
- `/admin` - Admin dashboard

### Navigation
- **Web/Desktop**: Side navigation rail
- **Mobile**: Bottom navigation bar

### State Management
The project uses Riverpod for state management. To add providers:

1. Create a provider file in the appropriate feature folder
2. Use `@riverpod` annotation for code generation
3. Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### Adding Features

1. **New Screen**: Create in `lib/features/[feature_name]/`
2. **Shared Widget**: Add to `lib/shared/widgets/`
3. **Model**: Add to `lib/shared/models/`
4. **Service**: Add to `lib/shared/services/`
5. **Route**: Update `lib/app/router.dart`

### Theme Customization
Edit `lib/shared/theme/app_theme.dart` to customize colors and styles.

## Next Steps

- [ ] Add backend API integration
- [ ] Implement authentication
- [ ] Add form validation
- [ ] Create data persistence layer
- [ ] Add unit and widget tests
- [ ] Implement responsive layouts
- [ ] Add error handling
- [ ] Set up CI/CD pipeline

## Useful Commands

```bash
# Run tests
flutter test

# Build for production
flutter build web
flutter build apk
flutter build ios

# Analyze code
flutter analyze

# Format code
dart format .

# Generate code (for Riverpod providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Troubleshooting

**Issue**: Dependencies not resolving
**Solution**: Run `flutter pub get` and ensure Flutter SDK is up to date

**Issue**: Web app not loading
**Solution**: Check browser console for errors, ensure `flutter run -d chrome` is used

**Issue**: Hot reload not working
**Solution**: Try hot restart (Shift+R in terminal) or full restart
