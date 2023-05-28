import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/summary.dart';
import '../my_theme.dart';

class SummaryBar extends StatelessWidget {
  static const double width = 888;
  static const double height = 28;

  const SummaryBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final controller = Provider.of<SummaryController>(context);
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 2,
      shadowColor: theme.shadow,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: DefaultTextStyle(
        style: TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.onTertiary),
        child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            color: theme.tertiary,
            child: Wrap(spacing: 20, children: [
              Text('IPH  ${controller.getData().iph}'),
              Text('Profit  ${controller.getData().profit}'),
              Text('Cost  ${controller.getData().cost}'),
              Text('Value  ${controller.getData().sellValue}'),
              Text('Jobs  ${controller.getData().jobCost}'),
              Text('In m3  ${controller.getData().inm3}'),
              Text('Out m3  ${controller.getData().outm3}'),
              Text('Time  ${controller.getData().time}')
            ])),
      ),
    );
  }
}
