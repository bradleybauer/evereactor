import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'hover_button.dart';

class BuildBuyToggleButtons extends StatefulWidget {
  const BuildBuyToggleButtons({Key? key}) : super(key: key);

  @override
  State<BuildBuyToggleButtons> createState() => _BuildBuyToggleButtonsState();
}

class _BuildBuyToggleButtonsState extends State<BuildBuyToggleButtons> {
  final padding = const EdgeInsets.fromLTRB(4, 3, 4, 3);

  bool left = false;

  final selected = theme.colors.tertiary;
  final onSelected = theme.colors.onTertiary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HoverButton(
            builder: (hovered) {
              return Padding(
                  padding: padding,
                  child: Text(
                    'build',
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 11,
                        color: hovered
                            ? theme.colors.onPrimary
                            : left
                                ? onSelected
                                : theme.colors.onBackground),
                  ));
            },
            borderRadius: 4,
            onTap: () {
              setState(() {
                left = true;
              });
            },
            hoveredElevation: 0,
            color: left ? selected : theme.colors.background,
            splashColor: theme.colors.onPrimary.withOpacity(.25),
            hoveredColor: theme.colors.primary),
        const SizedBox(width: 5),
        HoverButton(
            builder: (hovered) {
              return Padding(
                  padding: padding,
                  child: Text(
                    'buy',
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 11,
                        color: hovered
                            ? theme.colors.onPrimary
                            : !left
                                ? onSelected
                                : theme.colors.onBackground),
                  ));
            },
            borderRadius: 4,
            onTap: () {
              setState(() {
                left = false;
              });
            },
            hoveredElevation: 0,
            splashColor: theme.colors.onPrimary.withOpacity(.25),
            color: !left ? selected : theme.colors.background,
            hoveredColor: theme.colors.primary)
      ],
    );
  }
}
