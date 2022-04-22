import 'package:EveIndy/gui/widgets/table_text_field.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'flyout.dart';

class BpOptionsTableWidget extends StatelessWidget {
  const BpOptionsTableWidget({required this.style, Key? key}) : super(key: key);

  static const size = Size(172, 32);

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
      child: Flyout(
        verticalOffset: 0,
        openMode: FlyoutOpenMode.hover,
        align: FlyoutAlign.childLeftCenter,
        contentSize: size,
        content: const BpOptionsFlyoutContent(),
        closeTimeout: const Duration(),
        maxVotes: 1,
        child: RotatedBox(
          quarterTurns: 2,
          child: Icon(
            // Icons.settings,
            // Icons.keyboard_double_arrow_left,
            Icons.label_important_outline,
            // Icons.menu,
            // Icons.check_box_outline_blank_sharp,
            size: 14,
          ),
        ),
      ),
    );
  }
}

class BpOptionsFlyoutContent extends StatelessWidget {
  const BpOptionsFlyoutContent({Key? key}) : super(key: key);

  static const padding = 8.0;
  static const toolTipOffset = 19.0;
  static const duration= Duration(milliseconds:500);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: theme.surfaceVariant, borderRadius: BorderRadius.circular(4)),
      width: BpOptionsTableWidget.size.width,
      height: BpOptionsTableWidget.size.height,
      child: Row(
        children: [
          const SizedBox(width: padding),
          Tooltip(
            message: 'Material Efficiency',
            preferBelow: false,
            verticalOffset: toolTipOffset,
            waitDuration: duration,
            child: TableTextField(onChanged: (text) {}, initialText: '', hintText: 'ME', width: 25, maxNumDigits: 2),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Time Efficiency',
            preferBelow: false,
            verticalOffset: toolTipOffset,
            waitDuration: duration,
            child: TableTextField(onChanged: (text) {}, initialText: '', hintText: 'TE', width: 25, maxNumDigits: 2),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Max number of runs per blueprint',
            preferBelow: false,
            verticalOffset: toolTipOffset,
            waitDuration: duration,
            child: TableTextField(onChanged: (text) {}, initialText: '', hintText: 'Runs', width: 47, maxNumDigits: 6),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Max number of blueprints',
            preferBelow: false,
            verticalOffset: toolTipOffset,
            waitDuration: duration,
            child: TableTextField(onChanged: (text) {}, initialText: '', hintText: 'BPs', width: 35, maxNumDigits: 3),
          ),
          const SizedBox(width: padding),
        ],
      ),
    );
  }
}
