import 'package:flutter/material.dart';

class TableColumn {
  final Widget widget;
  final String? tooltipMessage;
  final void Function()? onTap;
  const TableColumn({required this.widget, this.tooltipMessage, this.onTap});
}

class TableHeader extends StatelessWidget {
  const TableHeader({
    required this.items,
    required this.flexs,
    this.color,
    this.height,
    Key? key,
  }) : super(key: key);

  final List<TableColumn> items;
  final double? height;
  final Color? color;
  final List<int> flexs;

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
            child: InkWell(
              onTap: items[i].onTap,
              child: widget,
            ));
      }
      widgets.add(Flexible(fit: FlexFit.tight, flex: flexs[i], child: widget));
    }
    return Container(color: color, height: height, child: Row(children: widgets));
  }
}
