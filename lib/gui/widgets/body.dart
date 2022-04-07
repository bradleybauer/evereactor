import 'package:EveIndy/gui/widgets/targets_table.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';

class Body extends StatelessWidget {
  const Body({this.width, this.verticalPadding, Key? key}) : super(key: key);

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
                Container(
                  width: width,
                  height: 35 + 4 * MyTheme.appBarPadding,
                  color: theme.colors.primary,
                ),
                Container(width: width, height: 200, color: theme.colors.background),
                Container(
                  width: width,
                  height: 200,
                  color: theme.colors.primary,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: TargetsTable(),
                  ),
                ),
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
            padding: EdgeInsets.fromLTRB(0, MyTheme.appBarPadding * 2 + verticalPadding!, 0, 0),
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
