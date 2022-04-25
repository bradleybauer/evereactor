import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import 'hover_button.dart';

class BuildBuyToggleButtons extends StatelessWidget {
  const BuildBuyToggleButtons({
    required this.onChange,
    required this.shouldBuild,
    Key? key,
  }) : super(key: key);

  static const padding = EdgeInsets.fromLTRB(4, 3, 4, 3);

  final bool shouldBuild;
  final void Function(bool) onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final selected = theme.tertiaryContainer;
    final onSelected = theme.onTertiaryContainer;
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
                            ? theme.onPrimary
                            : shouldBuild
                                ? onSelected
                                : theme.onBackground),
                  ));
            },
            borderRadius: 4,
            onTap: () => onChange(true),
            hoveredElevation: 0,
            color: shouldBuild ? selected : theme.background,
            splashColor: theme.onPrimary.withOpacity(.25),
            hoveredColor: theme.primary),
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
                            ? theme.onPrimary
                            : !shouldBuild
                                ? onSelected
                                : theme.onBackground),
                  ));
            },
            borderRadius: 4,
            onTap: () => onChange(false),
            hoveredElevation: 0,
            splashColor: theme.onPrimary.withOpacity(.25),
            color: !shouldBuild ? selected : theme.background,
            hoveredColor: theme.primary)
      ],
    );
  }
}
