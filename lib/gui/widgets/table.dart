import 'package:flutter/material.dart';

import '../my_theme.dart';

class TableContainer extends StatelessWidget {
  const TableContainer({
    required this.header,
    required this.listView,
    required this.listTextStyle,
    this.maxHeight = double.infinity,
    this.color,
    this.borderColor,
    this.borderRadius = 4,
    this.elevation = 0,
    this.clipBehavior = Clip.antiAlias,
    Key? key,
  }) : super(key: key);

  final Widget header;
  final Widget listView;
  final double maxHeight;
  final double elevation;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;
  final Clip clipBehavior;
  final TextStyle listTextStyle;

  static TableColumn getCol(int flex, {Widget? child, Alignment? align, EdgeInsets? padding, void Function()? onTap}) {
    return TableColumn(
        onTap: onTap,
        flex: flex,
        widget: Container(
          alignment: align ?? Alignment.centerRight,
          padding: padding,
          child: child,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final bRadius = borderRadius == null ? null : BorderRadius.circular(borderRadius!);
    return PhysicalModel(
      color: Colors.transparent,
      elevation: elevation,
      shadowColor: theme.shadow,
      borderRadius: bRadius,
      clipBehavior: clipBehavior,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: color,
          borderRadius: bRadius,
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            Flexible(child: DefaultTextStyle(style: listTextStyle, child: listView)),
          ],
        ),
      ),
    );
  }
}

class MyTableCell extends StatelessWidget {
  const MyTableCell(
    this.flex, {
    this.align,
    this.padding,
    this.child,
    Key? key,
  }) : super(key: key);

  final int flex;
  final Alignment? align;
  final EdgeInsets? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Container(
        padding: padding,
        alignment: align ?? Alignment.centerRight,
        child: child,
      ),
    );
  }
}

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
