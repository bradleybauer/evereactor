import 'package:flutter/material.dart';

class TableColumn {
  final Widget widget;
  final int flex;
  final String? tooltipMessage;
  final void Function()? onTap;
  const TableColumn({required this.widget, required this.flex, this.tooltipMessage, this.onTap});
}

class TableHeader extends StatelessWidget {
  const TableHeader({
    required this.items,
    this.textStyle,
    this.color,
    this.height,
    Key? key,
  }) : super(key: key);

  final List<TableColumn> items;
  final double? height;
  final Color? color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; ++i) {
      Widget widget = items[i].widget;
      if (items[i].tooltipMessage != null) {
        widget = Tooltip(
            message: items[i].tooltipMessage!,
            padding: const EdgeInsets.all(3),
            verticalOffset: 13,
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 600),
            child: widget);
      }
      if (items[i].onTap != null) {
        widget = Material(
            color: Colors.transparent,
            textStyle: textStyle,
            child: InkWell(
              onTap: items[i].onTap,
              child: widget,
            ));
      }
      widgets.add(Flexible(fit: FlexFit.tight, flex: items[i].flex, child: widget));
    }
    if (textStyle == null) {
      return Container(color: color, height: height, child: Row(children: widgets));
    }
    return DefaultTextStyle(
      style: textStyle!,
      child: Container(color: color, height: height, child: Row(children: widgets)),
    );
  }
}
