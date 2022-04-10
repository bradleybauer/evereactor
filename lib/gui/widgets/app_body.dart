import 'dart:math';

import 'package:flutter/material.dart';

import 'table_intermediates.dart';
import 'summary_bar.dart';
import 'table_inputs.dart';
import 'table_targets.dart';
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
                  height: SummaryBar.height + 4 * MyTheme.appBarPadding,
                  color: theme.surfaceVariant.withOpacity(.25),
                ),
                Container(
                  width: width,
                  color: theme.surfaceVariant.withOpacity(.75),
                  padding: const EdgeInsets.all(theme.appBarPadding * 2),
                  child: const TargetsTable(),
                ),
                Container(
                  width: width,
                  color: theme.surfaceVariant.withOpacity(.25),
                  padding: const EdgeInsets.all(theme.appBarPadding * 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Flexible(
                        flex: 7,
                        fit: FlexFit.tight,
                        child: IntermediatesTable(),
                      ),
                      SizedBox(width: theme.appBarPadding * 2),
                      Flexible(
                        flex: 5,
                        fit: FlexFit.tight,
                        child: InputsTable(),
                      ),
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
