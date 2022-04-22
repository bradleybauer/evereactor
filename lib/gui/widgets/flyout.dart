import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../platform.dart';
import '../my_theme.dart';
import 'flyout_controller.dart';

enum FlyoutOpenMode {
  tap,
  hover,
  custom, // Manage the controller directly.
}

enum FlyoutAlign {
  childLeftCenter,
  childTopLeft,
  childTopRight,
  appRight,
}

class Flyout extends StatefulWidget {
  /// Provide [closeTimeout] or [controller] but not both.
  const Flyout({
    required this.verticalOffset,
    required this.contentSize,
    required this.content,
    required this.child,
    required this.openMode,
    required this.align,
    // Note this only pads the right side of the window atm.
    this.windowPadding = 0,
    this.closeTimeout,
    this.controller,
    Key? key,
  })  : assert((closeTimeout != null && controller == null) || (closeTimeout == null && controller != null)),
        super(key: key);

  final double verticalOffset;
  final Widget content;
  final Size contentSize;
  final Widget child;
  final Duration? closeTimeout;
  final FlyoutOpenMode openMode;
  final FlyoutAlign align;
  final double windowPadding;
  final FlyoutController? controller;

  @override
  State<Flyout> createState() => _FlyoutState();
}

class _FlyoutState extends State<Flyout> {
  late FlyoutController controller;
  final layerLink = LayerLink();
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? FlyoutController(widget.closeTimeout!);
    controller.addListener(_handleStateChange);
  }

  @override
  void didUpdateWidget(covariant Flyout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      // Dispose the current controller
      controller.dispose();
      // Assign to the new controller
      controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleStateChange);
    // Dispose the controller not using a controller stored in widget
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  Offset getEntryOffset(BuildContext ctx, RenderBox childBox) {
    final childPos = childBox.localToGlobal(Offset.zero);
    switch (widget.align) {
      case FlyoutAlign.appRight:
        if (!Platform.isWeb()) {
          double dy = -widget.verticalOffset;
          double dx = MyTheme.appWidth - childPos.dx - widget.windowPadding - widget.contentSize.width;
          return Offset(dx, dy);
        } else {
          final windowWidth = MediaQuery.of(ctx).size.width;
          double dy = -widget.verticalOffset;
          double dx = windowWidth -
              childPos.dx -
              widget.windowPadding -
              widget.contentSize.width -
              max(0, windowWidth - MyTheme.appWidth) / 2 - // the app is centered in the browser
              32; // -32 there is extra padding on web
          return Offset(dx, dy);
        }
      case FlyoutAlign.childTopLeft:
        return Offset(0.0, -widget.verticalOffset);
      case FlyoutAlign.childTopRight:
        return Offset(0.0, -widget.verticalOffset);
      case FlyoutAlign.childLeftCenter:
        return Offset(-widget.verticalOffset, 0.0);
    }
  }

  void _handleStateChange() {
    final overlayState = Overlay.of(context);
    if (controller.isOpen && entry == null) {
      entry = getOverlayEntry();
      overlayState?.insert(entry!);
    } else if (!controller.isOpen) {
      entry?.remove();
      entry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget ret;

    switch (widget.openMode) {
      case FlyoutOpenMode.hover:
        ret = MouseRegion(
          // opaque: false,
          onEnter: (event) => controller.open(),
          onExit: (event) => controller.startCloseTimer(),
          child: widget.child,
        );
        break;
      case FlyoutOpenMode.tap:
        ret = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: controller.toggle,
          child: widget.child,
        );
        break;
      case FlyoutOpenMode.custom:
        ret = widget.child;
        break;
    }

    return CompositedTransformTarget(link: layerLink, child: ret);
  }

  OverlayEntry getOverlayEntry() {
    return OverlayEntry(
      builder: ((ctx) {
        final childBox = context.findRenderObject() as RenderBox;
        final offset = getEntryOffset(ctx, childBox);

        Alignment? followAnchor;
        Alignment? targetAnchor;
        switch (widget.align) {
          case FlyoutAlign.appRight:
            followAnchor = Alignment.bottomLeft;
            targetAnchor = Alignment.topLeft;
            break;
          case FlyoutAlign.childTopLeft:
            followAnchor = Alignment.bottomLeft;
            targetAnchor = Alignment.topLeft;
            break;
          case FlyoutAlign.childTopRight:
            followAnchor = Alignment.bottomRight;
            targetAnchor = Alignment.topRight;
            break;
          case FlyoutAlign.childLeftCenter:
            followAnchor = Alignment.centerRight;
            targetAnchor = Alignment.centerLeft;
            break;
        }

        return Center(
          child: CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            offset: offset,
            followerAnchor: followAnchor,
            targetAnchor: targetAnchor,
            child: MouseRegion(
              opaque: true,
              onEnter: (event) => controller.open(),
              onExit: (event) => controller.startCloseTimer(),
              child: Material(
                color: Colors.transparent,
                child: widget.content,
              ),
            ),
          ),
        );
      }),
    );
  }
}
