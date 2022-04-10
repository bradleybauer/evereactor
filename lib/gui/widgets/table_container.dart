import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'table_header.dart';

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
            Flexible(
              // defaults to fit: FlexFit.loose
              child: DefaultTextStyle(style: listTextStyle, child: listView),
            ),
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
