rm -rf build
mkdir build

flutter pub run build_runner build --delete-conflicting-outputs -o web:build/web/
cp -f build/web/cacheDbWorker.dart.js web/cacheDbWorker.dart.js

rm -rf build
mkdir build

flutter pub run build_runner build --release --delete-conflicting-outputs -o web:build/web/
cp -f build/web/cacheDbWorker.dart.js web/cacheDbWorker.dart.min.js