import 'package:EveIndy/models/industry_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/build_items.dart';
import '../../sde.dart';
import '../my_theme.dart';
import 'flyout.dart';
import 'table_text_field.dart';

class BpOptionsTableWidget extends StatelessWidget {
  const BpOptionsTableWidget({
    required this.tid,
    required this.adapter,
    Key? key,
  }) : super(key: key);

  static const size = Size(172, 32);

  final int tid;
  final BuildItemsAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
      child: Flyout(
        sideOffset: 0,
        openMode: FlyoutOpenMode.hover,
        align: FlyoutAlign.childLeftCenter,
        content: (ctx) => BpOptionsFlyoutContent(adapter: adapter, tid: tid),
        closeTimeout: const Duration(),
        maxVotes: 1,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(MyTheme.appBarPadding, 0, 0, 0),
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
      ),
    );
  }
}

class BpOptionsFlyoutContent extends StatelessWidget {
  const BpOptionsFlyoutContent({required this.adapter, required this.tid, Key? key}) : super(key: key);

  final int tid;
  final BuildItemsAdapter adapter;

  static const padding = 8.0;
  static const toolTipOffset = 19.0;
  static const duration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    var fields = <Widget>[
      Tooltip(
        message: 'Max number of blueprints',
        preferBelow: false,
        verticalOffset: toolTipOffset,
        waitDuration: duration,
        child: TableTextField(
            onChanged: (text) => adapter.setMaxBPs(tid, text != '' ? int.parse(text) : null),
            initialText: adapter.getMaxBPs(tid) != null ? adapter.getMaxBPs(tid).toString() : '',
            activeBorderColor: theme.primary,
            textColor: theme.onBackground,
            fillColor: theme.background,
            hintText: 'BPs',
            allowEmptyString: true,
            width: 35,
            maxNumDigits: 3),
      ),
    ];
    if (SDE.blueprints[tid]!.industryType != IndustryType.REACTION) {
      fields += <Widget>[
        Tooltip(
          message: 'Max number of runs per blueprint',
          preferBelow: false,
          verticalOffset: toolTipOffset,
          waitDuration: duration,
          child: TableTextField(
              activeBorderColor: theme.primary,
              textColor: theme.onBackground,
              fillColor: theme.background,
              onChanged: (text) => adapter.setMaxRuns(tid, text != '' ? int.parse(text) : null),
              initialText: adapter.getMaxRuns(tid) != null ? adapter.getMaxRuns(tid).toString() : '',
              hintText: 'Runs',
              allowEmptyString: true,
              width: 47,
              maxNumDigits: 6),
        ),
        Tooltip(
          message: 'Time Efficiency',
          preferBelow: false,
          verticalOffset: toolTipOffset,
          waitDuration: duration,
          child: TableTextField(
              activeBorderColor: theme.primary,
              textColor: theme.onBackground,
              fillColor: theme.background,
              onChanged: (text) => adapter.setTE(tid, text != '' ? int.parse(text) : null),
              initialText: adapter.getTE(tid) != null ? adapter.getTE(tid).toString() : '',
              hintText: 'TE',
              allowEmptyString: true,
              width: 25,
              maxNumDigits: 2),
        ),
        Tooltip(
          message: 'Material Efficiency',
          preferBelow: false,
          verticalOffset: toolTipOffset,
          waitDuration: duration,
          child: TableTextField(
              activeBorderColor: theme.primary,
              textColor: theme.onBackground,
              fillColor: theme.background,
              onChanged: (text) => adapter.setME(tid, text != '' ? int.parse(text) : null),
              initialText: adapter.getME(tid) != null ? adapter.getME(tid).toString() : '',
              hintText: 'ME',
              allowEmptyString: true,
              width: 25,
              maxNumDigits: 2),
        ),
      ];
    }
    return Container(
      padding: const EdgeInsets.all(padding / 2),
      decoration: BoxDecoration(color: theme.surfaceVariant, borderRadius: BorderRadius.circular(4)),
      child: Wrap(
        spacing: padding,
        direction: Axis.horizontal,
        children: fields,
      ),
    );
  }
}
