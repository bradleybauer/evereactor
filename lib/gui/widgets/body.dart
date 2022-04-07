import 'package:EveIndy/gui/widgets/summary_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'targets_table.dart';
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
                  color: theme.colors.surfaceVariant.withOpacity(.25),
                ),
                Container(
                  width: width,
                  color: theme.colors.surfaceVariant.withOpacity(.75),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: TargetsTable(),
                  ),
                ),
                Container(width: width, height: 200, color: theme.colors.surfaceVariant.withOpacity(.25)),
                Container(width: width, height: 200, color: theme.colors.surfaceVariant.withOpacity(.75)),
                Container(width: width, height: 200, color: theme.colors.surfaceVariant.withOpacity(.25)),
              ],
            ),
          ),
        ),
        Align(
          // Summary Box
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, MyTheme.appBarPadding * 2 + verticalPadding!, 0, 0),
            child: const SummaryBar(),
          ),
        ),
      ],
    );
  }
}
