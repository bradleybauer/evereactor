import 'dart:math' as math;

import 'package:flutter/material.dart';

// fun stuff in here: https://stackoverflow.com/questions/28350655/how-do-i-emulate-protected-methods-in-dart

class _MyHoverableWidget extends StatefulWidget {
  const _MyHoverableWidget({Key? key, required this.child, required this.callback}) : super(key: key);

  final Widget child;

  final void Function(bool)? callback;

  @override
  _MyHoverableWidgetState createState() => _MyHoverableWidgetState();
}

// inside your current widget
class _MyHoverableWidgetState extends State<_MyHoverableWidget> {
  // define a class variable to store the current state of your mouse pointer
  bool amIHovering = false;

  // store the position where your mouse pointer left the widget
  Offset exitFrom = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // callback when your mouse pointer enters the underlying widget
      // here you have to use 'PointerEvent'
      onEnter: (PointerEvent details) {
        setState(() {
          amIHovering = true;
          widget.callback!(amIHovering);
        });
      },

      // callback when your mouse pointer leaves the underlying widget
      onExit: (PointerEvent details) {
        setState(() {
          amIHovering = false;
          // storing the exit position
          exitFrom = details.localPosition; // You can use details.position if you are interested in the global position of your pointer.
          widget.callback!(amIHovering);
        });
      },

      // your underlying widget, can be anything
      child: widget.child,
    );
  }
}

@immutable
class DataRow2 extends DataRow {
  DataRow2(
      {required List<DataCell> cells,
      required this.getColor,
      LocalKey? key,
      void Function()? onLongPress,
      void Function(bool?)? onSelectChanged,
      bool selected = false,
      this.onHover})
      : super(
            cells: cells,
            color: MaterialStateProperty.all(Colors.white),
            key: key,
            onLongPress: onLongPress,
            onSelectChanged: onSelectChanged,
            selected: selected);
  final void Function(bool)? onHover;
  final Color Function(BuildContext) getColor;
}

class DataTable2 extends DataTable {
  DataTable2({
    Key? key,
    required List<DataColumn> columns,
    this.columnMinWidths,
    int? sortColumnIndex,
    bool sortAscending = true,
    ValueSetter<bool?>? onSelectAll,
    Decoration? decoration,
    MaterialStateProperty<Color?>? dataRowColor,
    double? dataRowHeight,
    TextStyle? dataTextStyle,
    MaterialStateProperty<Color?>? headingRowColor,
    double? headingRowHeight,
    TextStyle? headingTextStyle,
    double? horizontalMargin,
    double? columnSpacing,
    bool showCheckboxColumn = true,
    bool showBottomBorder = false,
    double? dividerThickness,
    required this.rows,
    double? checkboxHorizontalMargin,
    this.noStartPadding,
    TableBorder? border,
  })  : assert(columns.isNotEmpty),
        assert(sortColumnIndex == null || (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
        assert(!rows.any((DataRow2 row) => row.cells.length != columns.length)),
        assert(dividerThickness == null || dividerThickness >= 0),
        _onlyTextColumn = _initOnlyTextColumn(columns),
        super(
          columns: columns,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          onSelectAll: onSelectAll,
          decoration: decoration,
          dataRowColor: dataRowColor,
          dataRowHeight: dataRowHeight,
          dataTextStyle: dataTextStyle,
          headingRowColor: headingRowColor,
          headingRowHeight: headingRowHeight,
          headingTextStyle: headingTextStyle,
          horizontalMargin: horizontalMargin,
          columnSpacing: columnSpacing,
          showCheckboxColumn: showCheckboxColumn,
          showBottomBorder: showBottomBorder,
          dividerThickness: dividerThickness,
          rows: rows,
          checkboxHorizontalMargin: checkboxHorizontalMargin,
          border: border,
        );

  final List<DataRow2> rows;
  final bool? noStartPadding;

  final List<double>? columnMinWidths;

  // Set by the constructor to the index of the only Column that is
  // non-numeric, if there is exactly one, otherwise null.
  final int? _onlyTextColumn;
  static int? _initOnlyTextColumn(List<DataColumn> columns) {
    int? result;
    for (int index = 0; index < columns.length; index += 1) {
      final DataColumn column = columns[index];
      if (!column.numeric) {
        if (result != null) return null;
        result = index;
      }
    }
    return result;
  }

  static final LocalKey _headingRowKey = UniqueKey();

  /// The default height of the heading row.
  static const double _headingRowHeight = 56.0;

  /// The default horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  static const double _horizontalMargin = 24.0;

  /// The default horizontal margin between the contents of each data column.
  static const double _columnSpacing = 56.0;

  /// The default padding between the heading content and sort arrow.
  static const double _sortArrowPadding = 2.0;

  /// The default divider thickness.
  static const double _dividerThickness = 1.0;

  static const Duration _sortArrowAnimationDuration = Duration(milliseconds: 150);

  Widget _buildHeadingCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget label,
    required String? tooltip,
    required bool numeric,
    required VoidCallback? onSort,
    required bool sorted,
    required bool ascending,
    required MaterialStateProperty<Color?>? overlayColor,
    required double minWidth,
  }) {
    final ThemeData themeData = Theme.of(context);
    label = Container(
      constraints: BoxConstraints(minWidth: minWidth),
      alignment: Alignment.centerRight,
      child: Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[
          // ConstrainedBox(child: label, constraints: BoxConstraints(minWidth: minWidth)),
          // Container(
          //   child: label,
          //   constraints: BoxConstraints(minWidth: minWidth),
          //   alignment: Alignment.centerRight,
          // ),
          label,
          if (onSort != null) ...<Widget>[
            _SortArrow(
              visible: sorted,
              up: sorted ? ascending : null,
              duration: _sortArrowAnimationDuration,
            ),
            const SizedBox(width: _sortArrowPadding),
          ],
        ],
      ),
    );

    final TextStyle effectiveHeadingTextStyle = headingTextStyle ?? themeData.dataTableTheme.headingTextStyle ?? themeData.textTheme.subtitle2!;
    final double effectiveHeadingRowHeight = headingRowHeight ?? themeData.dataTableTheme.headingRowHeight ?? _headingRowHeight;
    label = Container(
      padding: padding,
      height: effectiveHeadingRowHeight,
      alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: AnimatedDefaultTextStyle(
        style: effectiveHeadingTextStyle,
        softWrap: false,
        duration: _sortArrowAnimationDuration,
        child: label,
      ),
    );
    if (tooltip != null) {
      label = Tooltip(
        message: tooltip,
        child: label,
      );
    }

    // TODO(dkwingsmt): Only wrap Inkwell if onSort != null. Blocked by
    // https://github.com/flutter/flutter/issues/51152
    label = InkWell(
      onTap: onSort,
      overlayColor: overlayColor,
      child: label,
    );
    return label;
  }

  Widget _buildDataCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget label,
    required bool numeric,
    required bool placeholder,
    required bool showEditIcon,
    required GestureTapCallback? onTap,
    required VoidCallback? onSelectChanged,
    required GestureTapCallback? onDoubleTap,
    required GestureLongPressCallback? onLongPress,
    required GestureTapDownCallback? onTapDown,
    required GestureTapCancelCallback? onTapCancel,
    required MaterialStateProperty<Color?>? overlayColor,
    required GestureLongPressCallback? onRowLongPress,
    required void Function(bool)? onHover,
  }) {
    final ThemeData themeData = Theme.of(context);
    if (showEditIcon) {
      const Widget icon = Icon(Icons.edit, size: 18.0);
      label = Expanded(child: label);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[label, icon],
      );
    }

    final TextStyle effectiveDataTextStyle = dataTextStyle ?? themeData.dataTableTheme.dataTextStyle ?? themeData.textTheme.bodyText2!;
    final double effectiveDataRowHeight = dataRowHeight ?? themeData.dataTableTheme.dataRowHeight ?? kMinInteractiveDimension;
    if (onHover != null) {
      label = _MyHoverableWidget(
        callback: onHover,
        child: Container(
          padding: padding,
          height: effectiveDataRowHeight,
          alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
          child: DefaultTextStyle(
            style: effectiveDataTextStyle.copyWith(
              color: placeholder ? effectiveDataTextStyle.color!.withOpacity(0.6) : null,
            ),
            child: DropdownButtonHideUnderline(child: label),
          ),
        ),
      );
    } else {
      label = Container(
        padding: padding,
        height: effectiveDataRowHeight,
        alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
        child: DefaultTextStyle(
          style: effectiveDataTextStyle.copyWith(
            color: placeholder ? effectiveDataTextStyle.color!.withOpacity(0.6) : null,
          ),
          child: DropdownButtonHideUnderline(child: label),
        ),
      );
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialStateProperty<Color?>? effectiveHeadingRowColor = headingRowColor ?? theme.dataTableTheme.headingRowColor;
    final MaterialStateProperty<Color?>? effectiveDataRowColor = dataRowColor ?? theme.dataTableTheme.dataRowColor;
    final MaterialStateProperty<Color?> defaultRowColor = MaterialStateProperty.resolveWith(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) return theme.colorScheme.primary.withOpacity(0.08);
        return null;
      },
    );
    final bool anyRowSelectable = rows.any((DataRow2 row) => row.onSelectChanged != null);
    final bool displayCheckboxColumn = showCheckboxColumn && anyRowSelectable;
    final Iterable<DataRow2> rowsWithCheckbox =
        displayCheckboxColumn ? rows.where((DataRow2 row) => row.onSelectChanged != null) : <DataRow2>[];
    final Iterable<DataRow2> rowsChecked = rowsWithCheckbox.where((DataRow2 row) => row.selected);
    final bool allChecked = displayCheckboxColumn && rowsChecked.length == rowsWithCheckbox.length;
    final bool anyChecked = displayCheckboxColumn && rowsChecked.isNotEmpty;
    final bool someChecked = anyChecked && !allChecked;
    final double effectiveHorizontalMargin = horizontalMargin ?? theme.dataTableTheme.horizontalMargin ?? _horizontalMargin;
    final double effectiveCheckboxHorizontalMarginStart =
        checkboxHorizontalMargin ?? theme.dataTableTheme.checkboxHorizontalMargin ?? effectiveHorizontalMargin;
    final double effectiveCheckboxHorizontalMarginEnd =
        checkboxHorizontalMargin ?? theme.dataTableTheme.checkboxHorizontalMargin ?? effectiveHorizontalMargin / 2.0;
    final double effectiveColumnSpacing = columnSpacing ?? theme.dataTableTheme.columnSpacing ?? _columnSpacing;

    final List<TableColumnWidth> tableColumns =
        List<TableColumnWidth>.filled(columns.length + (displayCheckboxColumn ? 1 : 0), const _NullTableColumnWidth());
    final List<TableRow> tableRows = List<TableRow>.generate(
      rows.length + 1, // the +1 is for the header row
      (int index) {
        final bool isSelected = index > 0 && rows[index - 1].selected;
        final bool isDisabled = index > 0 && anyRowSelectable && rows[index - 1].onSelectChanged == null;
        final Set<MaterialState> states = <MaterialState>{
          if (isSelected) MaterialState.selected,
          if (isDisabled) MaterialState.disabled,
        };
        // final Color? resolvedDataRowColor = index > 0 ? (rows[index - 1].color ?? effectiveDataRowColor)?.resolve(states) : null;
        final Color? resolvedDataRowColor = index > 0 ? rows[index - 1].getColor(context) : null;
        final Color? resolvedHeadingRowColor = effectiveHeadingRowColor?.resolve(<MaterialState>{});
        final Color? rowColor = index > 0 ? resolvedDataRowColor : resolvedHeadingRowColor;
        final BorderSide borderSide = Divider.createBorderSide(
          context,
          width: dividerThickness ?? theme.dataTableTheme.dividerThickness ?? _dividerThickness,
        );
        final Border? border = showBottomBorder
            ? Border(bottom: borderSide)
            : index == 0
                ? null
                : Border(top: borderSide);
        return TableRow(
          key: index == 0 ? _headingRowKey : rows[index - 1].key,
          decoration: BoxDecoration(
            border: border,
            color: rowColor ?? defaultRowColor.resolve(states),
          ),
          children: List<Widget>.filled(tableColumns.length, const _NullWidget()),
        );
      },
    );

    int rowIndex;

    int displayColumnIndex = 0;

    for (int dataColumnIndex = 0; dataColumnIndex < columns.length; dataColumnIndex += 1) {
      final DataColumn column = columns[dataColumnIndex];

      double paddingStart;
      if (dataColumnIndex == 0 && displayCheckboxColumn && checkboxHorizontalMargin != null) {
        paddingStart = effectiveHorizontalMargin;
      } else if (dataColumnIndex == 0 && displayCheckboxColumn) {
        paddingStart = effectiveHorizontalMargin / 2.0;
      } else if (dataColumnIndex == 0 && !displayCheckboxColumn) {
        paddingStart = effectiveHorizontalMargin;
      } else {
        paddingStart = effectiveColumnSpacing / 2.0;
      }

      final double paddingEnd;
      if (dataColumnIndex == columns.length - 1) {
        paddingEnd = effectiveHorizontalMargin;
      } else {
        paddingEnd = effectiveColumnSpacing / 2.0;
      }

      EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
        start: paddingStart,
        end: paddingEnd,
      );
      if (dataColumnIndex == _onlyTextColumn) {
        tableColumns[displayColumnIndex] = const IntrinsicColumnWidth(flex: 1.0);
      } else {
        tableColumns[displayColumnIndex] = const IntrinsicColumnWidth();
      }
      tableRows[0].children![displayColumnIndex] = _buildHeadingCell(
        context: context,
        padding: padding,
        label: column.label,
        minWidth: columnMinWidths == null ? 0.0 : columnMinWidths![displayColumnIndex],
        tooltip: column.tooltip,
        numeric: column.numeric,
        onSort: column.onSort != null ? () => column.onSort!(dataColumnIndex, sortColumnIndex != dataColumnIndex || !sortAscending) : null,
        sorted: dataColumnIndex == sortColumnIndex,
        ascending: sortAscending,
        overlayColor: effectiveHeadingRowColor,
      );
      rowIndex = 1;
      if (noStartPadding != null && noStartPadding!) {
        padding = EdgeInsetsDirectional.only(
          start: 8,
          end: paddingEnd,
        );
      }
      for (final DataRow2 row in rows) {
        final DataCell cell = row.cells[dataColumnIndex];
        tableRows[rowIndex].children![displayColumnIndex] = _buildDataCell(
          context: context,
          padding: padding,
          label: cell.child,
          numeric: column.numeric,
          placeholder: cell.placeholder,
          showEditIcon: cell.showEditIcon,
          onTap: cell.onTap,
          onDoubleTap: cell.onDoubleTap,
          onLongPress: cell.onLongPress,
          onTapCancel: cell.onTapCancel,
          onTapDown: cell.onTapDown,
          onSelectChanged: row.onSelectChanged == null ? null : () => row.onSelectChanged?.call(!row.selected),
          overlayColor: row.color ?? effectiveDataRowColor,
          onRowLongPress: row.onLongPress,
          onHover: row.onHover,
        );
        rowIndex += 1;
      }
      displayColumnIndex += 1;
    }

    return Container(
      decoration: decoration ?? theme.dataTableTheme.decoration,
      child: Material(
        type: MaterialType.transparency,
        child: Table(columnWidths: tableColumns.asMap(), children: tableRows, border: border),
      ),
    );
  }
}

class _NullTableColumnWidth extends TableColumnWidth {
  const _NullTableColumnWidth();

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) => throw UnimplementedError();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) => throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}

class _SortArrow extends StatefulWidget {
  const _SortArrow({
    Key? key,
    required this.visible,
    required this.up,
    required this.duration,
  }) : super(key: key);

  final bool visible;

  final bool? up;

  final Duration duration;

  @override
  _SortArrowState createState() => _SortArrowState();
}

class _SortArrowState extends State<_SortArrow> with TickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

  late AnimationController _orientationController;
  late Animation<double> _orientationAnimation;
  double _orientationOffset = 0.0;

  bool? _up;

  static final Animatable<double> _turnTween = Tween<double>(begin: 0.0, end: math.pi).chain(CurveTween(curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _opacityAnimation = CurvedAnimation(
      parent: _opacityController = AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
      curve: Curves.fastOutSlowIn,
    )..addListener(_rebuild);
    _opacityController.value = widget.visible ? 1.0 : 0.0;
    _orientationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _orientationAnimation = _orientationController.drive(_turnTween)
      ..addListener(_rebuild)
      ..addStatusListener(_resetOrientationAnimation);
    if (widget.visible) _orientationOffset = widget.up! ? 0.0 : math.pi;
  }

  void _rebuild() {
    setState(() {
      // The animations changed, so we need to rebuild.
    });
  }

  void _resetOrientationAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      assert(_orientationAnimation.value == math.pi);
      _orientationOffset += math.pi;
      _orientationController.value = 0.0; // TODO(ianh): This triggers a pointless rebuild.
    }
  }

  @override
  void didUpdateWidget(_SortArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool skipArrow = false;
    final bool? newUp = widget.up ?? _up;
    if (oldWidget.visible != widget.visible) {
      if (widget.visible && (_opacityController.status == AnimationStatus.dismissed)) {
        _orientationController.stop();
        _orientationController.value = 0.0;
        _orientationOffset = newUp! ? 0.0 : math.pi;
        skipArrow = true;
      }
      if (widget.visible) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
    if ((_up != newUp) && !skipArrow) {
      if (_orientationController.status == AnimationStatus.dismissed) {
        _orientationController.forward();
      } else {
        _orientationController.reverse();
      }
    }
    _up = newUp;
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _orientationController.dispose();
    super.dispose();
  }

  static const double _arrowIconBaselineOffset = -1.5;
  static const double _arrowIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Transform(
        transform: Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value)..setTranslationRaw(0.0, _arrowIconBaselineOffset, 0.0),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_upward,
          size: _arrowIconSize,
        ),
      ),
    );
  }
}
