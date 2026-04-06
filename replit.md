# Expensive Tracker App

A Flutter web application for tracking expenses.

## Tech Stack

- **Language**: Dart 3.8.0
- **Framework**: Flutter 3.32.0
- **Target**: Web (also supports Android, iOS, Linux, macOS, Windows)
- **Package Manager**: pub (Flutter)

## Project Structure

- `lib/main.dart` — Application entry point and main widget code
- `web/` — Web-specific assets (index.html, icons, manifest)
- `pubspec.yaml` — Dependencies and project metadata
- `pubspec.lock` — Locked dependency versions

## Development

The app runs as a Flutter web server in development mode:

```
flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0
```

This serves the app at `http://0.0.0.0:5000`.

## Deployment

Configured as a static site deployment:
- **Build**: `flutter build web --release`
- **Public directory**: `build/web`

## Notes

- The Dart SDK constraint in `pubspec.yaml` was adjusted to `^3.7.0` to be compatible with the Flutter 3.32.0 bundled Dart 3.8.0 SDK.
- `main.dart` was updated to remove experimental `dot-shorthands` syntax (e.g., `.fromSeed(...)` → `ColorScheme.fromSeed(...)`) for compatibility with Dart 3.8.0.
