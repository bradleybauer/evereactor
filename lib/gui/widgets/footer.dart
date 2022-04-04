import 'package:flutter/material.dart';

import 'footer_flyout_group.dart';
import '../my_theme.dart';

class Footer extends StatelessWidget {
  const Footer({this.height, this.width, Key? key}) : super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final stackWidgets = <Widget>[
      const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: FooterFlyoutGroup(),
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
