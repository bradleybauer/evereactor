import 'package:flutter/material.dart';

import 'footer_flyout_button.dart';
import '../my_theme.dart';

class Footer extends StatelessWidget {
  const Footer({double? height, double? width, Key? key})
      : height = height,
        width = width,
        super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    double iconHeight = MyTheme.appBarButtonHeight * .8;
    double iconVerticalPadding = MyTheme.appBarButtonHeight * .1;

    final stackWidgets = <Widget>[
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: theme.colors.primary),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: iconVerticalPadding),
                  child: Icon(Icons.question_mark, size: iconHeight, color: theme.colors.onPrimary),
                )), // Q/A Button
            const SizedBox(width: MyTheme.appBarPadding),
            FooterFlyoutButton(), // Copy multibutton
            const SizedBox(width: MyTheme.appBarPadding),
            Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: theme.colors.primary),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9, vertical: iconVerticalPadding),
                  child: Icon(Icons.memory, size: iconHeight, color: theme.colors.onPrimary),
                )),
            const SizedBox(width: MyTheme.appBarPadding),
            Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: theme.colors.primary),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: iconVerticalPadding),
                  child: Icon(Icons.settings, size: iconHeight, color: theme.colors.onPrimary),
                )), // Q/A Button
          ]),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
            child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: theme.colors.primary),
                width: 310,
                height: MyTheme.appBarButtonHeight) // Search Bar
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
