import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'hover_button.dart';

class TableAddDelButton extends StatelessWidget {
  const TableAddDelButton({
    Key? key,
    required this.closeButton,
    required this.onTap,
    required this.color,
    required this.hoveredColor,
    required this.splashColor,
  }) : super(key: key);

  final bool closeButton;
  final Color color;
  final Color hoveredColor;
  final Color splashColor;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      builder: (hovered) {
        return Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(closeButton ? Icons.close : Icons.add, size: 11, color: hovered ? theme.on(hoveredColor) : theme.on(color)));
      },
      borderRadius: 4,
      hoveredElevation: 0,
      color: color,
      hoveredColor: hoveredColor,
      splashColor: splashColor,
      onTap: onTap,
    );
  }
}
