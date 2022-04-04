import 'flyout_controller.dart';
import 'package:flutter/material.dart';

enum FlyoutOpenMode {
  tap,
  hover,
}

enum FlyoutCloseMode {
  tap,
  leave,
}

enum FlyoutAlign {
  left,
  center,
  right,
}

class Flyout extends StatefulWidget {
  const Flyout(
      {this.contentConstraints,
      this.verticalOffset,
      this.content,
      this.child,
      this.openMode = FlyoutOpenMode.hover,
      this.closeMode = FlyoutCloseMode.leave,
      this.align = FlyoutAlign.center,
      this.controller,
      Key? key})
      : super(key: key);

  final BoxConstraints? contentConstraints;
  final double? verticalOffset;
  final Widget? content;
  final Widget? child;
  final FlyoutOpenMode? openMode;
  final FlyoutCloseMode? closeMode;
  final FlyoutAlign? align;
  final FlyoutController? controller;

  @override
  State<Flyout> createState() => _FlyoutState();
}

class _FlyoutState extends State<Flyout> {
  // final popupKey = GlobalKey<>();
  FlyoutController controller = FlyoutController();

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? FlyoutController();
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
    // Dispose the controller if null
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
