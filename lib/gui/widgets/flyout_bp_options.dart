import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/build_items.dart';
import '../../models/industry_type.dart';
import '../../sde.dart';
import '../my_theme.dart';
import 'flyout.dart';
import 'flyout_controller.dart';
import 'hover_button.dart';
import 'table_text_field.dart';

class BpOptionsTableWidget extends StatefulWidget {
  const BpOptionsTableWidget({
    required this.tid,
    required this.controller,
    Key? key,
  }) : super(key: key);

  final int tid;
  final BuildItemsController controller;

  @override
  State<BpOptionsTableWidget> createState() => _BpOptionsTableWidgetState();
}

class _BpOptionsTableWidgetState extends State<BpOptionsTableWidget> {
  final flyoutController = FlyoutController(const Duration(), maxVotes: 1);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding / 2),
      child: Flyout(
        sideOffset: -2,
        openMode: FlyoutOpenMode.custom,
        controller: flyoutController,
        align: FlyoutAlign.childLeftCenter,
        content: (ctx) => BpOptionsFlyoutContent(controller: widget.controller, tid: widget.tid),
        // closeTimeout: const Duration(),
        maxVotes: 1,
        child: HoverButton(
          builder: (hovered) {
            return Padding(
              padding: const EdgeInsets.all(MyTheme.appBarPadding / 3),
              // padding: EdgeInsets.symmetric(horizontal:MyTheme.appBarPadding),
              child: Icon(
                // Icons.settings,
                // Icons.keyboard_double_arrow_left,
                // Icons.label_important_outline,
                Icons.menu,
                // Icons.check_box_outline_blank_sharp,
                size: 14,
                color: hovered ? theme.onPrimary : theme.onBackground,
              ),
            );
          },
          borderRadius: 3,
          hoveredElevation: 0,
          onTap: () => flyoutController.open(),
          color: theme.background,
          hoveredColor: theme.primary,
        ),
        // Padding(
        //   padding: EdgeInsets.fromLTRB(MyTheme.appBarPadding, 0, 0, 0),
        //   // padding: EdgeInsets.symmetric(horizontal:MyTheme.appBarPadding),
        //   child: RotatedBox(
        //     quarterTurns: 2,
        //     child: Icon(
        //       // Icons.settings,
        //       // Icons.keyboard_double_arrow_left,
        //       // Icons.label_important_outline,
        //       Icons.menu,
        //       // Icons.check_box_outline_blank_sharp,
        //       size: 14,
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

class BpOptionsFlyoutContent extends StatelessWidget {
  const BpOptionsFlyoutContent({required this.controller, required this.tid, Key? key}) : super(key: key);

  final int tid;
  final BuildItemsController controller;

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
            onChanged: (text) => controller.setMaxBPs(tid, text != '' ? int.parse(text) : null),
            initialText: controller.getMaxBPs(tid) != null ? controller.getMaxBPs(tid).toString() : '',
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
              onChanged: (text) => controller.setMaxRuns(tid, text != '' ? int.parse(text) : null),
              initialText: controller.getMaxRuns(tid) != null ? controller.getMaxRuns(tid).toString() : '',
              hintText: 'Runs',
              allowEmptyString: true,
              width: 47,
              maxNumDigits: 6),
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
              onChanged: (text) => controller.setME(tid, text != '' ? int.parse(text) : null),
              initialText: controller.getME(tid) != null ? controller.getME(tid).toString() : '',
              hintText: 'ME',
              allowEmptyString: true,
              width: 25,
              maxNumDigits: 2),
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
              onChanged: (text) => controller.setTE(tid, text != '' ? int.parse(text) : null),
              initialText: controller.getTE(tid) != null ? controller.getTE(tid).toString() : '',
              hintText: 'TE',
              allowEmptyString: true,
              width: 25,
              maxNumDigits: 2),
        ),
      ];
    }
    return Container(
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(color: theme.surfaceVariant, borderRadius: BorderRadius.circular(4)),
      child: Wrap(
        spacing: padding,
        direction: Axis.horizontal,
        children: fields,
      ),
    );
  }
}
