import 'package:flutter/cupertino.dart';

class FlyoutController extends ChangeNotifier {
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void show() {
    _isOpen = true;
    notifyListeners();
  }

  void hide() {
    _isOpen = false;
    notifyListeners();
  }
}
