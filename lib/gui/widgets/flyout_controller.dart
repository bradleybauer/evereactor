import 'package:flutter/material.dart';
import 'dart:async';

class FlyoutController extends ChangeNotifier {
  FlyoutController(this.closeTimeout);

  final Duration closeTimeout;

  // Allow open state of flyout to be controlled by multiple sources using boolean OR between each source.
  int _keepOpenVotes = 0;

  Timer? _closeTimer;
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void open() {
    _keepOpenVotes += 1;
    _isOpen = true;
    _closeTimer?.cancel();
    _closeTimer = null;
    notifyListeners();
  }

  void _closeNoVote() {
    if (_keepOpenVotes <= 0) {
      assert(_keepOpenVotes == 0);
      _keepOpenVotes = 0;
      _isOpen = false;
      _closeTimer?.cancel();
      _closeTimer = null;
      notifyListeners();
    }
  }

  void close() {
    _keepOpenVotes -= 1;
    _closeNoVote();
  }

  void startCloseTimer() {
    _keepOpenVotes -= 1;
    _closeTimer?.cancel();
    _closeTimer = Timer(closeTimeout, _closeNoVote);
  }
}
