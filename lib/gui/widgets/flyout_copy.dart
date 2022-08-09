import 'package:eve_reactor/controllers/controllers.dart';
import 'package:eve_reactor/controllers/schedule_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import 'hover_button.dart';

class CopyFlyout extends StatelessWidget {
  const CopyFlyout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputs = Provider.of<InputsTableController>(context);
    final targets = Provider.of<ProductsTableController>(context);
    final schedule = Provider.of<Build>(context).getSchedule();
    final theme = Provider.of<MyTheme>(context);
    final color = theme.surface;
    final hoveredColor = theme.primary;
    const textStyle = const TextStyle(fontFamily: 'NotoSans', fontSize: 12);
    return PhysicalModel(
      color: Colors.transparent,
      shadowColor: theme.shadow,
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        padding: const EdgeInsets.all(6),
        color: theme.secondaryContainer,
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, direction: Axis.vertical, spacing: 8, children: [
          HoverButton(
            builder: (hovered) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Copy Products', style: textStyle.copyWith(color: hovered ? theme.on(hoveredColor) : theme.on(color)))),
            color: color,
            hoveredColor: hoveredColor,
            hoveredElevation: 0,
            borderRadius: 3,
            onTap: () {
              final txt = targets.exportSpreadSheet();
              Clipboard.setData(ClipboardData(text: txt));
            },
          ),
          HoverButton(
            builder: (hovered) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Copy Inputs', style: textStyle.copyWith(color: hovered ? theme.on(hoveredColor) : theme.on(color)))),
            onTap: () {
              final txt = inputs.exportSpreadSheet();
              Clipboard.setData(ClipboardData(text: txt));
            },
            color: color,
            hoveredColor: hoveredColor,
            hoveredElevation: 0,
            borderRadius: 3,
          ),
          HoverButton(
            builder: (hovered) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Copy Schedule', style: textStyle.copyWith(color: hovered ? theme.on(hoveredColor) : theme.on(color)))),
            onTap: () {
              final txt = schedule.toString();
              Clipboard.setData(ClipboardData(text: txt));
            },
            color: color,
            hoveredColor: hoveredColor,
            hoveredElevation: 0,
            borderRadius: 3,
          ),
        ]),
      ),
    );
  }
}
