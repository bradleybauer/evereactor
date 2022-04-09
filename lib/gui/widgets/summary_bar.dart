import 'package:flutter/material.dart';

import '../my_theme.dart';

class SummaryBar extends StatelessWidget {
  static const double SummaryBarWidth = 650;

  const SummaryBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 2,
      shadowColor: theme.shadow,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(width: SummaryBarWidth, height: 35, color: theme.primary),
    );
  }
}
