// adapted from https://medium.com/@gshubham030/custom-dropdown-menu-in-flutter-7d8d1e026c6b

import 'dart:async';
import 'package:flutter/material.dart';

class OverlayMenu extends StatefulWidget {
  final BorderRadius? borderRadius;
  Color? backgroundColor = Colors.white;
  final Widget child;

  OverlayMenu({
    Key? key,
    this.borderRadius,
    required this.child,
  }) : super(key: key);

  @override
  _OverlayMenuState createState() => _OverlayMenuState();
}

class _OverlayMenuState extends State<OverlayMenu> with SingleTickerProviderStateMixin {
  final GlobalKey _key = LabeledGlobalKey("button_icon");
  bool isMenuOpen = false;
  Offset buttonPosition = Offset.zero;
  Size buttonSize = Size.zero;
  OverlayEntry? _overlayEntry;
  BorderRadius _borderRadius = BorderRadius.circular(8);
  // late AnimationController _animationController;

  @override
  void initState() {
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 250),
    // );

    _borderRadius = widget.borderRadius ?? _borderRadius;

    super.initState();
  }

  @override
  void dispose() {
    // _animationController.dispose();
    super.dispose();
  }

  findButton() {
    RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void closeMenu() {
    _overlayEntry!.remove();
    // _animationController.reverse();
    isMenuOpen = !isMenuOpen;
  }

  void openMenu() {
    findButton();
    // _animationController.forward();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context)!.insert(_overlayEntry!);
    isMenuOpen = !isMenuOpen;
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        key: _key,
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
        onPressed: () {
          if (isMenuOpen) {
            closeMenu();
          } else {
            openMenu();
          }
        },
        child: const Text('Options'));
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition.dy - 14, // + buttonSize.height / 2,
          left: buttonPosition.dx + 146,
          // width: buttonSize.width,
          child: _MyTimedHoverableWidget(
            duration: const Duration(milliseconds: 500),
            callback: (b) {
              if (!b) {
                // closeMenu();
              }
            },
            child: Material(
              color: Colors.grey[50],
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: _borderRadius,
                  border: Border.all(color: Colors.grey[300] as Color, width: 1),
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MyTimedHoverableWidget extends StatefulWidget {
  const _MyTimedHoverableWidget({Key? key, required this.child, required this.callback, required this.duration}) : super(key: key);

  final Duration duration;
  final Widget child;

  final void Function(bool)? callback;

  @override
  _MyTimedHoverableWidgetState createState() => _MyTimedHoverableWidgetState();
}

// inside your current widget
class _MyTimedHoverableWidgetState extends State<_MyTimedHoverableWidget> {
  // define a class variable to store the current state of your mouse pointer
  bool amIHovering = false;

  // store the position where your mouse pointer left the widget
  Offset exitFrom = Offset(0, 0);

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    // timer = Timer(Duration(seconds: 5), () {
    //   setState(() {
    //     widget.callback!(amIHovering);
    //   });
    // });
    return MouseRegion(
      // callback when your mouse pointer enters the underlying widget
      // here you have to use 'PointerEvent'
      onEnter: (PointerEvent details) {
        timer?.cancel();

        setState(() {
          amIHovering = true;
          widget.callback!(amIHovering);
        });
      },

      // callback when your mouse pointer leaves the underlying widget
      onExit: (PointerEvent details) {
        amIHovering = false;
        timer = Timer(widget.duration, () {
          if (!amIHovering) {
            setState(() {
              // storing the exit position
              exitFrom = details.localPosition; // You can use details.position if you are interested in the global position of your pointer.
              widget.callback!(amIHovering);
            });
          }
        });
      },

      // your underlying widget, can be anything
      child: widget.child,
    );
  }
}
