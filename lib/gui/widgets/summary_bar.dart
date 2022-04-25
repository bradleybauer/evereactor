import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';

class SummaryBar extends StatelessWidget {
  static const double width = 650;
  static const double height = 35;

  const SummaryBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 2,
      shadowColor: theme.shadow,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(width: width, height: height, color: theme.tertiary),
    );
  }
}
