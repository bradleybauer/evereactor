import 'loader_hook_stub.dart' if (dart.library.io) 'loader_hook_desktop.dart' if (dart.library.html) 'loader_hook_web.dart';

class LoaderHook {
  static void hook() => LoaderHookInterface.hook();
}
