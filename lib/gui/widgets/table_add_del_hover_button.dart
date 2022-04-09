import 'package:flutter/material.dart';

import 'hover_button.dart';

class TableAddDelButton extends StatelessWidget {
  const TableAddDelButton({
    Key? key,
    required this.closeButton,
    required this.onTap,
    required this.color,
    required this.hoveredColor,
    required this.iconColor,
    required this.iconHoveredColor,
    required this.splashColor,
  }) : super(key: key);

  final bool closeButton;
  final Color color;
  final Color hoveredColor;
  final Color iconColor;
  final Color iconHoveredColor;
  final Color splashColor;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      builder: (hovered) {
        return Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(closeButton ? Icons.close : Icons.add, size: 11, color: hovered ? iconHoveredColor : iconColor));
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
