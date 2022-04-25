import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    this.mouseCursor=MouseCursor.defer,
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
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    Widget widget = child;
    if (onTap != null) {
      widget = Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: mouseCursor,
          splashColor: splashColor,
          onTap: onTap,
          child: widget,
        ),
      );
    }
    return AnimatedPhysicalModel(
      color: color,
      duration: MyTheme.buttonFocusDuration,
      elevation: elevation,
      shadowColor: theme.shadow,
      shape: BoxShape.rectangle,
      clipBehavior: Clip.antiAlias,
      borderRadius: borderRadius == null ? BorderRadius.zero : BorderRadius.circular(borderRadius!),
      child: Container(
        decoration: BoxDecoration(
          border: borderColor == null ? null : Border.all(color: borderColor!),
          borderRadius: borderRadius == null ? null : BorderRadius.circular(borderRadius!),
        ),
        child: widget,
      ),
    );
  }
}
