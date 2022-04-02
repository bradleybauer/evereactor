import 'package:flutter/material.dart';

import 'package:EveIndy/gui/my_theme.dart';

class Footer extends StatelessWidget {
  const Footer({double? height, double? width, Key? key})
      : height = height,
        width = width,
        super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final stackWidgets = <Widget>[
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 40, color: theme.colors.primary), // Optimize Button (use Icon.memory)
            const SizedBox(width: MyTheme.appBarPadding),
            Container(width: 40, height: 40, color: theme.colors.primary), // Options Button
            const SizedBox(width: MyTheme.appBarPadding),
            Container(width: 40, height: 40, color: theme.colors.primary), // Copy Flyout with hover effect (looks like button)
          ]),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: Container(width: 310, height: 40, color: theme.colors.primary), // Search Bar
        ), // Search Bar
      ),
    ];

    return Container(
      color: theme.colors.secondaryContainer,
      width: width,
      height: height,
      child: Stack(children: stackWidgets),
    );
  }
}
