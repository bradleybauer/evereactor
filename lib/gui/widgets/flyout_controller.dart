import 'dart:async';
import 'package:flutter/material.dart';

class FlyoutController extends ChangeNotifier {
  FlyoutController(this.closeTimeout);

  final Duration closeTimeout;
  Timer? _closeTimer;
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void open() {
    _isOpen = true;
    _closeTimer?.cancel();
    _closeTimer = null;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    _closeTimer?.cancel();
    _closeTimer = null;
    notifyListeners();
  }

  void startCloseTimer() {
    _closeTimer?.cancel();
    _closeTimer = Timer(closeTimeout, close);
  }
}
