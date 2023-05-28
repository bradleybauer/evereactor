import 'package:flutter/material.dart';

import 'flyout_controller.dart';

enum FlyoutOpenMode {
  hover,
  custom, // Manage the controller directly.
}

// this is trash i know
enum FlyoutAlign {
  childRightCenter,
  dropup,
  dropdown,
  childBottomCenter,
  childLeftCenter,
  childTopLeft,
  childTopRight,
}

class Flyout extends StatefulWidget {
  /// Provide [closeTimeout] or [controller] but not both.
  const Flyout({
    required this.content,
    required this.child,
    required this.openMode,
    required this.align,
    this.sideOffset = 0,
    this.closeTimeout,
    this.controller,
    this.maxVotes = 2,
    Key? key,
  })  : assert((closeTimeout != null && controller == null) || (closeTimeout == null && controller != null)),
        super(key: key);

  final double sideOffset;
  final Widget Function(BuildContext) content;
  final Widget child;
  final Duration? closeTimeout;
  final FlyoutOpenMode openMode;
  final FlyoutAlign align;
  final FlyoutController? controller;
  final int maxVotes;

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
    controller = widget.controller ?? FlyoutController(widget.closeTimeout!, maxVotes: widget.maxVotes);
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

  void _handleStateChange() {
    if (controller.isOpen && (entry == null || controller.getDidContentChange())) {
      entry = getOverlayEntry();
      Overlay.of(context).insert(entry!);
    } else if (!controller.isOpen) {
      entry?.remove();
      entry = null;
    }
    controller.setDidContentChange(false);
  }

  OverlayEntry getOverlayEntry() {
    return OverlayEntry(
      builder: ((ctx) {
        final offset = getEntryOffset(ctx);

        Alignment? followAnchor;
        Alignment? targetAnchor;
        switch (widget.align) {
          case FlyoutAlign.childTopLeft:
            followAnchor = Alignment.bottomLeft;
            targetAnchor = Alignment.topLeft;
            break;
          case FlyoutAlign.childTopRight:
            followAnchor = Alignment.bottomRight;
            targetAnchor = Alignment.topRight;
            break;

          case FlyoutAlign.childRightCenter:
            followAnchor = Alignment.centerLeft;
            targetAnchor = Alignment.centerLeft;
            break;
          case FlyoutAlign.childLeftCenter:
            followAnchor = Alignment.centerRight;
            targetAnchor = Alignment.centerRight;
            break;
          case FlyoutAlign.childBottomCenter:
            followAnchor = Alignment.topCenter;
            targetAnchor = Alignment.topCenter;
            break;
          case FlyoutAlign.dropdown:
            followAnchor = Alignment.topCenter;
            targetAnchor = Alignment.topCenter;
            break;
          case FlyoutAlign.dropup:
            followAnchor = Alignment.bottomRight;
            targetAnchor = Alignment.bottomRight;
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
              // opaque: false, // must be false, otherwise nested overlays will close each other
              onEnter: (_) => controller.open(),
              onExit: (_) => controller.startCloseTimer(),
              child: Material(
                color: Colors.transparent,
                child: widget.content(ctx),
              ),
            ),
          ),
        );
      }),
    );
  }

  Offset getEntryOffset(BuildContext ctx) {
    switch (widget.align) {
      case FlyoutAlign.dropup:
        return Offset(0.0, widget.sideOffset);
      case FlyoutAlign.dropdown:
      case FlyoutAlign.childBottomCenter:
      case FlyoutAlign.childTopLeft:
      case FlyoutAlign.childTopRight:
        return Offset(0.0, -widget.sideOffset);

      case FlyoutAlign.childRightCenter:
      case FlyoutAlign.childLeftCenter:
        return Offset(-widget.sideOffset, 0.0);
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
      case FlyoutOpenMode.custom:
        ret = widget.child;
        break;
    }
    return CompositedTransformTarget(link: layerLink, child: ret);
  }
}
