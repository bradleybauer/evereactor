import 'package:EveIndy/gui/widgets/my_animated_container.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';

class HoverButton extends StatefulWidget {
  const HoverButton(
      {required this.builder,
      required this.onTap,
      Key? key,
      required this.color,
      required this.hoveredColor,
      this.splashColor,
      this.shadowColor,
      this.borderRadius,
      this.borderColor,
      this.elevation = 0,
      this.hoveredElevation = 3})
      : super(key: key);

  final Widget Function(bool) builder;
  final void Function() onTap;

  final Color color;
  final Color hoveredColor;
  final Color? splashColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double? borderRadius;
  final double elevation;
  final double hoveredElevation;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _focused = false;
  void onHover(hovered) {
    setState(() {
      _focused = hovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: MouseCursor.uncontrolled,
        onEnter: (e) {
          onHover(true);
        },
        onExit: (e) {
          onHover(false);
        },
        child: MyAnimatedContainer(
          child: widget.builder(_focused),
          color: _focused ? widget.hoveredColor : widget.color,
          elevation: _focused ? widget.hoveredElevation : widget.elevation,
          borderRadius: widget.borderRadius,
          borderColor: widget.borderColor,
          shadowColor: widget.shadowColor,
          onTap: widget.onTap,
          splashColor: widget.splashColor,
        ));
  }
}
