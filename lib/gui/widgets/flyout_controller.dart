import 'dart:async';

import 'package:flutter/material.dart';

class FlyoutController extends ChangeNotifier {
  FlyoutController(this.closeTimeout);

  final Duration closeTimeout;

  // TODO this does not work always because onExit of MouseRegion is sometimes not called.
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

  void startCloseTimer() {
    _keepOpenVotes -= 1;
    _closeTimer?.cancel();
    _closeTimer = Timer(closeTimeout, _closeNoVote);
  }

  void close() {
    _keepOpenVotes -= 1;
    _closeNoVote();
  }

  // Used in flyout tap mode
  void toggle() {
    if (isOpen) {
      forceClose();
    } else {
      open();
    }
  }

  // Sometimes, the MouseRegion fails to keep onEnter/onExit balanced and so the flyout can get stuck open. In this case
  // allow the user to click outside of the flyout content to forcefully close it.
  void forceClose() {
    _keepOpenVotes = 0;
    _closeNoVote();
  }

  void _closeNoVote() {
    if (_keepOpenVotes <= 0) {
      _keepOpenVotes = 0;
      _isOpen = false;
      _closeTimer?.cancel();
      _closeTimer = null;
      notifyListeners();
    }
  }
}
