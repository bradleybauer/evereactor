# FOR DEBUG MODE
rm -rf build
mkdir build

flutter pub run build_runner build --delete-conflicting-outputs -o web:build/web/
cp build/web/persistenceWorker.dart.js web/persistenceWorker.dart.js

# FOR RELEASE MODE
# rm -rf build
# mkdir build
# 
# flutter pub run build_runner build --release --delete-conflicting-outputs -o web:build/web/
# cp build/web/persistenceWorker.dart.js web/persistenceWorker.dart.min.js