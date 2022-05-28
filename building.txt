# FOR DEBUG MODE
flutter pub run build_runner build --delete-conflicting-outputs
# FOR RELEASE MODE
flutter pub run build_runner build --release --delete-conflicting-outputs

# to use the canvaskit renderer on web use
flutter run -d chrome --web-renderer canvaskit --release
# to use the html renderer on web use
flutter run -d chrome --release
