import 'package:flutter/material.dart';

import '../my_theme.dart';

class Content extends StatelessWidget {
  const Content({this.width, this.verticalPadding, Key? key}) : super(key: key);

  final double? verticalPadding;

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding!),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: width, height: 35 + 2 * MyTheme.appBarPadding, color: theme.colors.primary),
                Container(width: width, height: 200, color: theme.colors.background),
                Container(width: width, height: 200, color: theme.colors.primary),
                Container(width: width, height: 200, color: theme.colors.background),
                Container(width: width, height: 200, color: theme.colors.primary),
              ],
            ),
          ),
        ),
        Align(
          // Summary Box
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: MyTheme.appBarPadding + verticalPadding!),
            child: PhysicalModel(
              color: Colors.grey,
              elevation: 2,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(width: width! * .8, height: 35, color: theme.colors.tertiaryContainer),
            ),
          ),
        ),
      ],
    );
  }
}
