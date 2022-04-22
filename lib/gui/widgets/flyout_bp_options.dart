import 'package:EveIndy/adapters/table_targets.dart';
import 'package:EveIndy/gui/widgets/table_text_field.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'flyout.dart';

class BpOptionsTableWidget extends StatelessWidget {
  const BpOptionsTableWidget({required this.adapter, required this.index, Key? key}) : super(key: key);

  static const size = Size(172, 32);

  final TargetsTableAdapter adapter;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
      child: Flyout(
        verticalOffset: 0,
        openMode: FlyoutOpenMode.hover,
        align: FlyoutAlign.childLeftCenter,
        contentSize: size,
        content: BpOptionsFlyoutContent(adapter: adapter, index: index),
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
  const BpOptionsFlyoutContent({required this.adapter, required this.index, Key? key}) : super(key: key);

  final TargetsTableAdapter adapter;
  final int index;

  static const padding = 8.0;
  static const toolTipOffset = 19.0;
  static const duration = Duration(milliseconds: 500);

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
            child: TableTextField(
                onChanged: (text) => adapter.setME(index, text != '' ? int.parse(text) : null),
                initialText: adapter.getME(index) != null ? adapter.getME(index).toString() : '',
                hintText: 'ME',
                allowEmptyString: true,
                width: 25,
                maxNumDigits: 2),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Time Efficiency',
            preferBelow: false,
            verticalOffset: toolTipOffset,
            waitDuration: duration,
            child: TableTextField(
                onChanged: (text) => adapter.setTE(index, text != '' ? int.parse(text) : null),
                initialText: adapter.getTE(index) != null ? adapter.getTE(index).toString() : '',
                hintText: 'TE',
                allowEmptyString: true,
                width: 25,
                maxNumDigits: 2),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Max number of runs per blueprint',
            preferBelow: false,
            verticalOffset: toolTipOffset,
            waitDuration: duration,
            child: TableTextField(
                onChanged: (text) => adapter.setMaxRuns(index, text != '' ? int.parse(text) : null),
                initialText: adapter.getMaxRuns(index) != null ? adapter.getMaxRuns(index).toString() : '',
                hintText: 'Runs',
                allowEmptyString: true,
                width: 47,
                maxNumDigits: 6),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Max number of blueprints',
            preferBelow: false,
            verticalOffset: toolTipOffset,
            waitDuration: duration,
            child: TableTextField(
                onChanged: (text) => adapter.setMaxBPs(index, text != '' ? int.parse(text) : null),
                initialText: adapter.getMaxBPs(index) != null ? adapter.getMaxBPs(index).toString() : '',
                hintText: 'BPs',
                allowEmptyString: true,
                width: 35,
                maxNumDigits: 3),
          ),
          const SizedBox(width: padding),
        ],
      ),
    );
  }
}
