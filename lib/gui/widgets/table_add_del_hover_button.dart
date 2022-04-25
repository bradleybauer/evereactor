import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  static const double innerPadding = 2;
  static const double iconSize = 11;
  static const double width = innerPadding * 2 + iconSize;

  final bool closeButton;
  final Color color;
  final Color hoveredColor;
  final Color splashColor;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return HoverButton(
      builder: (hovered) {
        return Container(
            width: width,
            padding: const EdgeInsets.all(innerPadding),
            child: Icon(closeButton ? Icons.close : Icons.add, size: iconSize, color: hovered ? theme.on(hoveredColor) : theme.on(color)));
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
