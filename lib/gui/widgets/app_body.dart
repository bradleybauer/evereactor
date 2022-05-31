import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final theme = Provider.of<MyTheme>(context);
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
                  color: theme.surfaceVariant.withOpacity(.75),
                  padding: EdgeInsets.all(MyTheme.appBarPadding * 2),
                  child: const TargetsTable(),
                ),
                Container(
                  width: width,
                  color: theme.surfaceVariant.withOpacity(.25),
                  padding: EdgeInsets.all(MyTheme.appBarPadding * 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Flexible(
                        flex: 7,
                        fit: FlexFit.tight,
                        child: const IntermediatesTable(),
                      ),
                      SizedBox(width: MyTheme.appBarPadding * 2),
                      const Flexible(
                        flex: 5,
                        fit: FlexFit.tight,
                        child: const InputsTable(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
