# semedi

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

- Run: `flutter pub run build_runner build --delete-conflicting-outputs`
- It creates/updates the `api_client/` directory.
- DO NOT commit generated files— they're ignored via .gitignore.

## How to Generate API Client

1. Update Patched Spec
   - `curl http://your-ip:8000/api-spec.json -o openapi_patched.json`
   - open it and find "loc" block then Change "items": { "anyOf": [ { "type": "string" }, { "type": "integer" } ] } to: `"items": { "type": "string" }`
   - move the openapi_patched.json to the project root and edit openapi_config.dart
   - Delete old caches `rm -rf api_client/ .dart_tool/openapi-generator-cache.json`
   - then `flutter pub run build_runner build --delete-conflicting-outputs`
2. Go to pubspec.yaml of the generated folder
   - sdk: ^3.10.0 - Unlock modern Dart
   - cd api_client
   - flutter pub get
   - dart run build_runner build --delete-conflicting-outputs
   - cd ..
   - flutter pub get
3. Root pubspec Dependency
   - dependencies:
     my_api_client:
     path: ./api_client
