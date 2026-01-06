# Project Structure

```
flutter_birmingham_hub/
│
├── lib/
│   ├── main.dart                          # App entry point with Riverpod setup
│   │
│   ├── app/                               # App-level configuration
│   │   ├── router.dart                    # go_router configuration with all routes
│   │   └── navigation_shell.dart          # Navigation wrapper (rail + bottom nav)
│   │
│   ├── features/                          # Feature modules (vertical slices)
│   │   ├── home/
│   │   │   └── home_screen.dart          # Landing page with feature overview
│   │   │
│   │   ├── cfp/                          # Call for Papers
│   │   │   └── cfp_screen.dart           # Talk proposal submission form
│   │   │
│   │   ├── speakers/                     # Speakers management
│   │   │   └── speakers_screen.dart      # Speaker directory/listing
│   │   │
│   │   ├── agenda/                       # Event scheduling
│   │   │   └── agenda_screen.dart        # Event timeline/schedule
│   │   │
│   │   ├── feedback/                     # Feedback collection
│   │   │   └── feedback_screen.dart      # Feedback form with rating
│   │   │
│   │   └── admin/                        # Administration
│   │       └── admin_screen.dart         # Admin dashboard with stats
│   │
│   └── shared/                           # Shared resources
│       ├── widgets/                      # Reusable UI components
│       │   └── README.md
│       │
│       ├── theme/                        # Theme configuration
│       │   └── app_theme.dart            # Material 3 theme (light + dark)
│       │
│       ├── services/                     # Business logic services
│       │   └── README.md
│       │
│       └── models/                       # Data models
│           ├── speaker_model.dart        # Speaker entity
│           ├── event_model.dart          # Event entity
│           ├── cfp_submission_model.dart # CFP submission entity
│           └── README.md
│
├── web/                                  # Web-specific files
│   ├── index.html                        # HTML entry point
│   ├── manifest.json                     # PWA manifest
│   └── icons/                            # App icons
│       └── README.md
│
├── test/                                 # Test files
│   └── widget_test.dart                  # Basic widget tests
│
├── pubspec.yaml                          # Dependencies and metadata
├── analysis_options.yaml                 # Linter rules
├── .gitignore                            # Git ignore rules
├── README.md                             # Project documentation
├── QUICKSTART.md                         # Quick start guide
└── PROJECT_STRUCTURE.md                  # This file
```

## Key Architectural Decisions

### 1. Feature-First Organization
Each feature (cfp, speakers, agenda, etc.) is self-contained in its own folder, making it easy to:
- Locate related code
- Scale the application
- Work on features independently

### 2. Shared Resources
Common code is centralized in `shared/`:
- **widgets/**: Reusable UI components
- **theme/**: Consistent styling
- **services/**: Business logic (API, storage, etc.)
- **models/**: Data structures used across features

### 3. Routing Strategy
- **go_router**: Declarative routing with type safety
- **ShellRoute**: Persistent navigation shell across routes
- **Responsive Navigation**: Rail for web/desktop, bottom bar for mobile

### 4. State Management
- **Riverpod**: Modern, compile-safe state management
- **ProviderScope**: Wraps entire app in main.dart
- Ready for code generation with `riverpod_generator`

### 5. Platform Support
- **Web**: Progressive Web App (PWA) ready
- **Mobile**: iOS and Android support
- **Desktop**: Windows, macOS, Linux compatible

## Adding New Features

### Example: Adding a "Sponsors" Feature

1. **Create feature folder:**
   ```
   lib/features/sponsors/
   ├── sponsors_screen.dart
   ├── widgets/
   │   └── sponsor_card.dart
   └── providers/
       └── sponsors_provider.dart
   ```

2. **Add route in `router.dart`:**
   ```dart
   GoRoute(
     path: '/sponsors',
     name: 'sponsors',
     pageBuilder: (context, state) => const NoTransitionPage(
       child: SponsorsScreen(),
     ),
   ),
   ```

3. **Update navigation in `navigation_shell.dart`:**
   - Add navigation destination
   - Update index mapping
   - Add navigation handler

## Dependencies Overview

### Core
- `flutter`: Framework
- `flutter_riverpod`: State management
- `go_router`: Routing

### Utilities
- `equatable`: Value equality
- `json_annotation`: JSON serialization

### Dev Dependencies
- `build_runner`: Code generation
- `riverpod_generator`: Provider generation
- `json_serializable`: JSON code generation
- `flutter_lints`: Code quality

## Best Practices

1. **Keep features independent**: Minimize cross-feature dependencies
2. **Use shared resources**: Don't duplicate common code
3. **Follow naming conventions**: `feature_name_screen.dart`, `feature_name_provider.dart`
4. **Write tests**: Add tests in `test/` mirroring `lib/` structure
5. **Document complex logic**: Add comments for non-obvious code
6. **Use const constructors**: Improve performance with const widgets
7. **Responsive design**: Use `MediaQuery` and `LayoutBuilder` for adaptive UIs
