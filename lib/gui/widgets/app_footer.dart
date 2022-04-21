import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'flyout_button_group.dart';
import 'search_bar.dart';

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
      const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: SearchBar(),
        ),
      ),
    ];

    return Container(
      color: theme.surface,
      width: width,
      height: height,
      child: Stack(children: stackWidgets),
    );
  }
}
