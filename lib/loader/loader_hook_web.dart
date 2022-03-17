// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

class LoaderHookInterface {
  static void hook() {
    querySelector("#loader")?.remove();
    return;
    // Future.delayed(const Duration(seconds: 2), () {
    //   // remove loader
    //   querySelector("#loader")?.remove();
    // });
  }
}
