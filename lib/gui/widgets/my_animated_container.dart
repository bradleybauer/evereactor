import 'package:flutter/material.dart';

import '../my_theme.dart';

class MyAnimatedContainer extends StatelessWidget {
  const MyAnimatedContainer({
    required this.child,
    required this.color,
    required this.elevation,
    this.splashColor,
    this.borderColor,
    this.borderRadius,
    this.shadowColor = Colors.black,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Color color;
  final double elevation;
  final Color? splashColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double? borderRadius;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Widget widget = child;
    if (onTap != null) {
      widget = Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: splashColor,
          onTap: onTap,
          child: widget,
        ),
      );
    }
    return AnimatedPhysicalModel(
      color: Colors.transparent,
      duration: MyTheme.buttonFocusDuration,
      elevation: elevation,
      shadowColor: theme.shadow,
      shape: BoxShape.rectangle,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: AnimatedContainer(
        decoration: BoxDecoration(
          border: borderColor == null ? null : Border.all(color: borderColor!, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          color: color,
        ),
        duration: MyTheme.buttonFocusDuration,
        child: widget,
      ),
    );
  }
}
