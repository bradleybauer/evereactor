import 'package:flutter/material.dart';

import 'intermediates_table.dart';
import 'summary_bar.dart';
import 'inputs_table.dart';
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
                  color: theme.surfaceVariant.withOpacity(.25),
                ),
                Container(
                  width: width,
                  color: theme.surfaceVariant.withOpacity(.75),
                  padding: const EdgeInsets.all(20),
                  child: const TargetsTable(),
                ),
                Container(
                  width: width,
                  color: theme.surfaceVariant.withOpacity(.25),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: const [
                      IntermediatesTable(),
                      SizedBox(width: theme.appBarPadding * 2),
                      // Expanded(child: Container()),
                      InputsTable(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          // Summary Box
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, theme.appBarPadding * 2 + verticalPadding!, 0, 0),
            child: const SummaryBar(),
          ),
        ),
      ],
    );
  }
}
