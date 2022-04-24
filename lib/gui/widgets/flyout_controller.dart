import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class FlyoutController extends ChangeNotifier {
  FlyoutController(this.closeTimeout, {this.maxVotes = 2});

  FlyoutController? linkedController;

  final Duration closeTimeout;

  // keep some data to pass to the overlay
  bool _contentChanged = false;

  // This kind of fixes the issue where keepOpenVotes get unbalanced due to MouseRegion onExit/onEnter discontinuities.
  final int maxVotes;

  // Allow open state of flyout to be controlled by multiple sources using boolean OR between each source.
  int _keepOpenVotes = 0;

  Timer? _closeTimer;
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void open() {
    _keepOpenVotes = min(_keepOpenVotes + 1, maxVotes);
    final wasOpen = _isOpen;
    _isOpen = true;
    _closeTimer?.cancel();
    _closeTimer = null;
    // if (!wasOpen) notifyListeners();
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
    if (_keepOpenVotes <= 0 && (linkedController == null || !linkedController!.isOpen)) {
      _keepOpenVotes = 0;
      final wasClosed = !_isOpen;
      _isOpen = false;
      _closeTimer?.cancel();
      _closeTimer = null;
      // if (!wasClosed) notifyListeners();
      notifyListeners();
    }
  }

  bool getDidContentChange() => _contentChanged;
  void setDidContentChange(bool x) => _contentChanged = x;

  // Connects to [controller] so that this remains open if [controller] is open
  void connect(FlyoutController controller) {
    linkedController = controller;
  }

  void disconnect() {
    linkedController = null;
  }
}
